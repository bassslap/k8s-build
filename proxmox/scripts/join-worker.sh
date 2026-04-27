#!/bin/bash

# This script is used by the worker nodes to join the Kubernetes cluster.

# Set the Kubernetes master node IP address
MASTER_IP="<MASTER_IP>"

# Set the token and discovery hash (these should be securely retrieved or passed as environment variables)
TOKEN="<TOKEN>"
DISCOVERY_HASH="<DISCOVERY_HASH>"

# Join the Kubernetes cluster
kubeadm join $MASTER_IP:6443 --token $TOKEN --discovery-token-ca-cert-hash $DISCOVERY_HASH

# Optionally, you can add any additional configuration or commands needed for the worker node here.