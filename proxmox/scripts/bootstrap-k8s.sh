#!/usr/bin/env bash
set -euo pipefail

MASTER_IP="${MASTER_IP:?MASTER_IP is required}"
WORKER_IPS_CSV="${WORKER_IPS:?WORKER_IPS is required}"
SSH_USER="${SSH_USER:?SSH_USER is required}"
SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY:?SSH_PRIVATE_KEY is required}"
K8S_VERSION="${K8S_VERSION:-1.30}"
POD_CIDR="${POD_CIDR:-10.244.0.0/16}"
K8S_SERIES="v$(echo "$K8S_VERSION" | awk -F. '{print $1 "." $2}')"

SSH_PRIVATE_KEY="${SSH_PRIVATE_KEY/#\~/$HOME}"
IFS=',' read -r -a WORKER_IPS <<< "$WORKER_IPS_CSV"
ALL_NODES=("$MASTER_IP" "${WORKER_IPS[@]}")

ssh_opts=(
  -i "$SSH_PRIVATE_KEY"
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=10
  -o ServerAliveInterval=15
  -o ServerAliveCountMax=8
  -o TCPKeepAlive=yes
)

run_ssh() {
  local host="$1"
  local cmd="$2"
  ssh "${ssh_opts[@]}" "${SSH_USER}@${host}" "$cmd"
}

run_remote_script() {
  local host="$1"
  local script
  local attempt
  local exit_code=0

  script="$(cat)"

  for attempt in $(seq 1 5); do
    if ssh "${ssh_opts[@]}" "${SSH_USER}@${host}" \
      "sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a APT_LISTCHANGES_FRONTEND=none bash -s" \
      <<<"$script"; then
      return 0
    fi

    exit_code=$?
    if [[ $exit_code -ne 255 || $attempt -eq 5 ]]; then
      return $exit_code
    fi

    echo "SSH session to ${host} dropped, retrying (${attempt}/5)..." >&2
    wait_for_ssh "$host"
    sleep 5
  done

  return $exit_code
}

wait_for_apt() {
  local host="$1"
  run_remote_script "$host" <<'EOS'
set -euo pipefail

if command -v cloud-init >/dev/null 2>&1; then
  sudo cloud-init status --wait || true
fi

while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 \
  || sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
  || sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 \
  || sudo fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
  sleep 5
done

sudo dpkg --configure -a
EOS
}

wait_for_ssh() {
  local host="$1"
  local stable_checks=0
  echo "Waiting for SSH on ${host}..."
  for _ in $(seq 1 60); do
    if ssh "${ssh_opts[@]}" "${SSH_USER}@${host}" 'echo ok' >/dev/null 2>&1; then
      stable_checks=$((stable_checks + 1))
      if [[ $stable_checks -ge 3 ]]; then
        echo "SSH ready on ${host}"
        return 0
      fi
      sleep 5
      continue
    fi
    stable_checks=0
    sleep 5
  done
  echo "Timed out waiting for SSH on ${host}" >&2
  return 1
}

common_setup() {
  local host="$1"
  echo "Configuring node ${host}..."
  run_remote_script "$host" <<EOS
set -euo pipefail
echo "[${host}] disabling swap"
sudo swapoff -a
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

echo "[${host}] installing container runtime dependencies"
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https gnupg lsb-release containerd

echo "[${host}] configuring containerd"
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "[${host}] configuring Kubernetes apt repository"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_SERIES}/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_SERIES}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

echo "[${host}] installing Kubernetes packages"
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
EOS
}

for node in "${ALL_NODES[@]}"; do
  wait_for_ssh "$node"
  wait_for_apt "$node"
  common_setup "$node"
done

echo "Initializing control plane on ${MASTER_IP}..."
run_remote_script "$MASTER_IP" <<EOS
set -euo pipefail
if [[ ! -f /etc/kubernetes/admin.conf ]]; then
  sudo kubeadm init --pod-network-cidr='${POD_CIDR}'
fi
mkdir -p \$HOME/.kube
sudo cp /etc/kubernetes/admin.conf \$HOME/.kube/config
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml
EOS

JOIN_COMMAND="$(run_ssh "$MASTER_IP" "sudo kubeadm token create --print-join-command")"
if [[ -z "$JOIN_COMMAND" ]]; then
  echo "Failed to generate kubeadm join command" >&2
  exit 1
fi

echo "Joining workers to the cluster..."
for worker in "${WORKER_IPS[@]}"; do
  echo "Joining worker ${worker}..."
  run_remote_script "$worker" <<EOS
set -euo pipefail
if [[ ! -f /etc/kubernetes/kubelet.conf ]]; then
  ${JOIN_COMMAND}
else
  echo "Worker already has kubelet config, skipping join"
fi
EOS
done

echo "Kubernetes bootstrap completed."
