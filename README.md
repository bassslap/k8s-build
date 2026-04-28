# Kubernetes Cluster on Proxmox

Automated deployment of a production-ready 3-node Kubernetes cluster on Proxmox VE using OpenTofu/Terraform.

## Features

- **Fully Automated**: Single command deployment from infrastructure to running cluster
- **Production Ready**: 16GB RAM, 8 vCPU per node, Calico CNI, persistent storage
- **Modern Stack**: Kubernetes v1.30, containerd runtime, local-path storage provisioner
- **Infrastructure as Code**: OpenTofu/Terraform with bpg/proxmox provider

## Architecture

- **1 Master Node**: Control plane + API server (10.100.1.101)
- **2 Worker Nodes**: Application workloads (10.100.1.102, 10.100.1.103)
- **Network**: /14 subnet (10.100.0.0/14)
- **Storage**: Rancher local-path-provisioner (default StorageClass)
- **CNI**: Calico v3.28.2

## Quick Start

### Prerequisites

- Proxmox VE server (tested on Proxmox 7.x+)
- Ubuntu cloud-init template (ID 9001)
- OpenTofu or Terraform installed
- SSH key at `~/.ssh/id_rsa`

### Deploy

```bash
# Clone repository
git clone https://github.com/bassslap/k8s-build.git
cd k8s-build/proxmox

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Proxmox details

# Deploy infrastructure
tofu init
tofu apply -auto-approve

# Install Kubernetes
bash scripts/wait-for-vms.sh
bash scripts/install-k8s.sh
```

Total deployment time: ~5-10 minutes

## Verify Cluster

```bash
# SSH to master
ssh ubuntu@10.100.1.101

# Check nodes
kubectl get nodes -o wide

# Check storage
kubectl get storageclass

# Check system pods
kubectl get pods -A
```

## Configuration

Edit `proxmox/terraform.tfvars`:

```hcl
proxmox_host     = "https://10.100.0.10:8006"
proxmox_api_user = "admin@pve"
proxmox_api_token = "your-token-here"

vm_memory = 16384  # MB per VM
vm_cpu    = 8      # vCPUs per VM

master_ip  = "10.100.1.101"
worker1_ip = "10.100.1.102"
worker2_ip = "10.100.1.103"
```

## Project Structure

```
k8s-build/
├── README.md                      # This file
├── .gitignore                     # Excludes sensitive files
└── proxmox/
    ├── main.tf                    # VM resource definitions
    ├── variables.tf               # Input variables
    ├── providers.tf               # Provider configuration
    ├── versions.tf                # Provider version constraints
    ├── outputs.tf                 # Output values
    ├── terraform.tfvars.example   # Template configuration
    └── scripts/
        ├── install-k8s.sh         # Main installation script
        └── wait-for-vms.sh        # VM readiness check
```

## Troubleshooting

**VMs don't respond to SSH:**
```bash
# Check VM status in Proxmox
# Wait for cloud-init to complete (~2 minutes)
bash scripts/wait-for-vms.sh
```

**Installation fails:**
```bash
# Re-run installation (idempotent)
bash scripts/install-k8s.sh
```

**Destroy and recreate:**
```bash
tofu destroy -auto-approve
tofu apply -auto-approve
```

## Tech Stack

- **IaC**: OpenTofu (Terraform fork)
- **Provider**: bpg/proxmox >= 0.66.0
- **Kubernetes**: v1.30.14
- **Container Runtime**: containerd 2.2.1
- **CNI**: Calico v3.28.2
- **Storage**: Rancher local-path-provisioner v0.0.30
- **OS**: Ubuntu 24.04 (cloud-init)

## License

MIT
