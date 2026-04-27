#!/bin/bash

# Update package index
apt-get update

# Install necessary packages for Kubernetes
apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Add Kubernetes repository
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update package index again
apt-get update

# Install Kubernetes components
apt-get install -y kubelet kubeadm kubectl

# Mark them to hold back from upgrades
apt-mark hold kubelet kubeadm kubectl

# Initialize the Kubernetes master node
kubeadm init --pod-network-cidr=192.168.0.0/16

# Set up kubeconfig for the root user
export KUBECONFIG=/etc/kubernetes/admin.conf

# Set up kubeconfig for the regular user (replace 'your-username' with the actual username)
mkdir -p /home/your-username/.kube
cp -i /etc/kubernetes/admin.conf /home/your-username/.kube/config
chown $(id -u your-username):$(id -g your-username) /home/your-username/.kube/config

# Install a pod network add-on (Weave Net in this case)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Print message indicating completion
echo "Kubernetes master node initialized successfully."