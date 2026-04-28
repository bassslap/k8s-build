#!/usr/bin/env bash
# Quick manual Kubernetes installation guide

echo "=== Kubernetes Manual Installation ==="
echo ""
echo "VMs are ready at:"
echo "  Master:   10.100.1.101"
echo "  Worker 1: 10.100.1.102"  
echo "  Worker 2: 10.100.1.103"
echo "  User: ubuntu / Password: ubuntu123!"
echo ""
echo "SSH into each node and run these commands:"
echo ""
echo "=========================================="
echo "ON ALL NODES (master + both workers):"
echo "=========================================="
cat << 'EOF'

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
cat <<MODS | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
MODS
sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl params
cat <<SYSCTL | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
SYSCTL
sudo sysctl --system

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repo
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

EOF

echo ""
echo "=========================================="
echo "ON MASTER ONLY (10.100.1.101):"
echo "=========================================="
cat << 'EOF'

# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml

# Get join command
kubeadm token create --print-join-command

EOF

echo ""
echo "=========================================="
echo "ON WORKERS (10.100.1.102 and .103):"
echo "=========================================="
echo "Run the 'kubeadm join' command from the master output"
echo ""
echo "=========================================="
echo "VERIFY:"
echo "=========================================="
echo "On master: kubectl get nodes"
echo ""
