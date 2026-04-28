# Proxmox Kubernetes Infrastructure

Technical documentation for the OpenTofu/Terraform configuration.

## Architecture

### VMs
- **k8s-master** (VM 251): 10.100.1.101 - Control plane
- **k8s-worker-1** (VM 252): 10.100.1.102 - Worker node
- **k8s-worker-2** (VM 253): 10.100.1.103 - Worker node

### Specifications
- **Memory**: 16GB per VM
- **CPU**: 8 vCPUs per VM
- **Disk**: 32GB per VM (from template)
- **Network**: /14 subnet (10.100.0.0/14)
- **Gateway**: 10.100.0.1
- **DNS**: 8.8.8.8, 8.8.4.4

## Files

### Core Terraform Files
- **main.tf**: VM resource definitions using bpg/proxmox provider
- **variables.tf**: Input variable declarations
- **providers.tf**: Proxmox provider configuration
- **versions.tf**: Provider version constraints
- **outputs.tf**: Output values (VM IPs, etc.)
- **terraform.tfvars**: Your local configuration (gitignored)
- **terraform.tfvars.example**: Template for configuration

### Scripts
- **scripts/install-k8s.sh**: Complete Kubernetes installation
  - Installs containerd, kubeadm, kubectl, kubelet on all nodes
  - Initializes master with kubeadm
  - Deploys Calico CNI
  - Installs local-path storage provisioner
  - Joins worker nodes to cluster
- **scripts/wait-for-vms.sh**: Waits for VMs to be SSH-ready

## Usage

### Initial Setup
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your Proxmox details
vim terraform.tfvars

# Initialize provider
tofu init
```

### Deploy Infrastructure
```bash
# Preview changes
tofu plan

# Apply configuration
tofu apply -auto-approve
```

### Install Kubernetes
```bash
# Wait for VMs to be ready
bash scripts/wait-for-vms.sh

# Install Kubernetes on all nodes
bash scripts/install-k8s.sh
```

### Access Cluster
```bash
# SSH to master
ssh ubuntu@10.100.1.101

# Default password: ubuntu123!
# Change password after first login
```

### Destroy Infrastructure
```bash
tofu destroy -auto-approve
```

## Configuration Variables

Key variables in `terraform.tfvars`:

```hcl
# Proxmox Connection
proxmox_host      = "https://10.100.0.10:8006"
proxmox_api_user  = "admin@pve"
proxmox_api_token = "your-token-id=your-token-secret"
proxmox_node      = "pve"

# VM Template
template_id = 9001  # Ubuntu 24.04 cloud-init template

# VM Resources
vm_memory = 16384   # MB
vm_cpu    = 8       # vCPUs
vm_disk   = 32      # GB

# Network Configuration
master_ip  = "10.100.1.101"
worker1_ip = "10.100.1.102"
worker2_ip = "10.100.1.103"
gateway    = "10.100.0.1"
```

## Provider Details

Using **bpg/proxmox** provider (>= 0.66.0):
- More actively maintained than telmate/proxmox
- Better cloud-init support
- Improved SSH configuration handling
- Direct API token authentication

## Network Architecture

The cluster uses a /14 subnet (10.100.0.0/14) which covers:
- 10.100.0.0 - 10.103.255.255
- Supports 262,144 IP addresses
- Master and workers in 10.100.1.0/24 range

## Kubernetes Installation Details

The `install-k8s.sh` script performs these steps:

1. **Common Setup** (all nodes):
   - Disable swap
   - Load kernel modules (overlay, br_netfilter)
   - Configure sysctl for networking
   - Install containerd with systemd cgroup driver
   - Add Kubernetes repository
   - Install kubelet, kubeadm, kubectl

2. **Master Initialization**:
   - Run `kubeadm init` with pod CIDR 10.244.0.0/16
   - Configure kubectl for ubuntu user
   - Deploy Calico CNI
   - Install local-path storage provisioner
   - Generate join token

3. **Worker Join**:
   - Execute join command on each worker
   - Workers connect to master and join cluster

4. **Verification**:
   - Display node status
   - Display storage classes
   - Confirm cluster health

## Storage

**Local Path Provisioner** (Rancher):
- Dynamically provisions PersistentVolumes
- Uses local storage on each node
- Set as default StorageClass
- Path: `/opt/local-path-provisioner`

Test storage:
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
EOF
```

## Troubleshooting

### VMs not accessible
```bash
# Check Proxmox console for cloud-init status
# Cloud-init takes ~2 minutes to complete

# Verify network connectivity
ping 10.100.1.101

# Check SSH manually
ssh -v ubuntu@10.100.1.101
```

### Installation fails
```bash
# Re-run installation (idempotent)
bash scripts/install-k8s.sh

# Check individual node
ssh ubuntu@10.100.1.101
sudo systemctl status kubelet
sudo journalctl -xeu kubelet
```

### State issues
```bash
# If state becomes corrupted
rm terraform.tfstate*
tofu import proxmox_virtual_environment_vm.master 251
tofu import proxmox_virtual_environment_vm.worker[0] 252
tofu import proxmox_virtual_environment_vm.worker[1] 253
```