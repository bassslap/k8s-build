#!/usr/bin/env bash
set -euo pipefail

MASTER_IP="${1:-10.100.1.101}"
WORKER1_IP="${2:-10.100.1.102}"
WORKER2_IP="${3:-10.100.1.103}"
SSH_USER="ubuntu"
SSH_KEY="${HOME}/.ssh/id_rsa"

echo "=========================================="
echo "Kubernetes Installation Script"
echo "=========================================="
echo "Master: $MASTER_IP"
echo "Worker 1: $WORKER1_IP"
echo "Worker 2: $WORKER2_IP"
echo ""

# Common setup script for all nodes
COMMON_SETUP='
set -euo pipefail

echo "[$(hostname)] Disabling swap..."
sudo swapoff -a
sudo sed -i "/ swap / s/^/#/" /etc/fstab

echo "[$(hostname)] Loading kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo "[$(hostname)] Setting sysctl parameters..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system >/dev/null

echo "[$(hostname)] Installing containerd..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq containerd apt-transport-https ca-certificates curl gpg

echo "[$(hostname)] Configuring containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd >/dev/null 2>&1

echo "[$(hostname)] Adding Kubernetes repository..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

echo "[$(hostname)] Installing kubelet, kubeadm, kubectl..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl >/dev/null
sudo systemctl enable kubelet >/dev/null 2>&1

echo "[$(hostname)] ✓ Common setup complete"
'

# Master initialization script
MASTER_INIT='
set -euo pipefail

echo "[$(hostname)] Initializing Kubernetes control plane..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.100.1.101

echo "[$(hostname)] Setting up kubectl for ubuntu user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[$(hostname)] Installing Calico CNI..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml

echo "[$(hostname)] Installing local-path storage provisioner..."
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "[$(hostname)] Generating join command..."
kubeadm token create --print-join-command > /tmp/join-command.sh
chmod 644 /tmp/join-command.sh

echo "[$(hostname)] ✓ Master initialization complete"
'

echo "=========================================="
echo "Step 1/6: Installing prerequisites on all nodes"
echo "=========================================="

echo "→ Master ($MASTER_IP)..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${MASTER_IP}" "$COMMON_SETUP"

echo ""
echo "→ Worker 1 ($WORKER1_IP)..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${WORKER1_IP}" "$COMMON_SETUP"

echo ""
echo "→ Worker 2 ($WORKER2_IP)..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${WORKER2_IP}" "$COMMON_SETUP"

echo ""
echo "=========================================="
echo "Step 2/6: Initializing master node"
echo "=========================================="
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${MASTER_IP}" "$MASTER_INIT"

echo ""
echo "=========================================="
echo "Step 3/6: Retrieving join command"
echo "=========================================="
JOIN_COMMAND=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${MASTER_IP}" 'cat /tmp/join-command.sh')
echo "Join command: $JOIN_COMMAND"

echo ""
echo "=========================================="
echo "Step 4/6: Joining worker nodes to cluster"
echo "=========================================="

echo "→ Worker 1 ($WORKER1_IP)..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${WORKER1_IP}" "sudo $JOIN_COMMAND"

echo ""
echo "→ Worker 2 ($WORKER2_IP)..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${WORKER2_IP}" "sudo $JOIN_COMMAND"

echo ""
echo "=========================================="
echo "Step 5/6: Installing storage provisioner"
echo "=========================================="
echo "Waiting 20 seconds for Calico to initialize..."
sleep 20

echo "Installing local-path storage class..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${MASTER_IP}" 'kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml'

echo "Setting local-path as default storage class..."
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${MASTER_IP}" 'kubectl patch storageclass local-path -p '"'"'{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'"'"''

echo ""
echo "=========================================="
echo "Step 6/6: Verifying cluster status"
echo "=========================================="
echo "Waiting 30 seconds for nodes to register..."
sleep 30

echo "Cluster nodes:"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${MASTER_IP}" 'kubectl get nodes -o wide'

echo ""
echo "Storage classes:"
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "${SSH_USER}@${MASTER_IP}" 'kubectl get storageclass'

echo ""
echo "=========================================="
echo "✓ Kubernetes cluster installation complete!"
echo "=========================================="
echo ""
echo "Access your cluster:"
echo "  ssh ${SSH_USER}@${MASTER_IP}"
echo "  kubectl get nodes"
echo "  kubectl get pods -A"
echo ""
