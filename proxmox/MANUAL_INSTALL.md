# Manual Kubernetes Installation Guide

## VM Details
- Master: 10.100.1.101 (ubuntu/ubuntu123!)
- Worker 1: 10.100.1.102 (ubuntu/ubuntu123!)
- Worker 2: 10.100.1.103 (ubuntu/ubuntu123!)
- All nodes: 16GB RAM, 8 vCPU

## Installation Steps

### 1. Install on ALL nodes (master + workers)

SSH to each node and run:

```bash
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl params
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd apt-transport-https ca-certificates curl gpg

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes packages
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
```

### 2. Initialize Master (10.100.1.101 only)

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.100.1.101
```

**Save the `kubeadm join` command from the output!**

Set up kubectl for ubuntu user:
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Install Calico CNI:
```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml
```

Wait for master to be ready:
```bash
kubectl get nodes
```

### 3. Join Workers (10.100.1.102 and 10.100.1.103)

Run the join command from step 2 on each worker:
```bash
sudo kubeadm join 10.100.1.101:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### 4. Verify Cluster

On the master:
```bash
kubectl get nodes
kubectl get pods -A
```

All nodes should show `Ready` status after a minute or two.

## Quick SSH Access

```bash
# Master
ssh ubuntu@10.100.1.101

# Worker 1
ssh ubuntu@10.100.1.102

# Worker 2
ssh ubuntu@10.100.1.103
```
