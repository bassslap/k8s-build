# Kubernetes on Proxmox with OpenTofu

This project uses a split approach:

- Terraform provisions and configures VMs (IDs, CPU/memory, networking, cloud-init user account).
- A bootstrap script installs and configures Kubernetes (init control plane, join workers).

## Project Structure

- **main.tf**: Active root deployment stack (bpg/proxmox provider + VM provisioning + bootstrap trigger).
- **scripts/bootstrap-k8s.sh**: Active Kubernetes bootstrap path.
- **terraform.tfvars**: Active default input file used by root runs.

- **environments/production/**: Legacy path kept for reference. Root stack is the supported path.

- **templates/**: Legacy cloud-init templates (not used by active root stack).

- **scripts/**: Contains scripts for initializing the master and joining worker nodes.
  - **init-master.sh**: Script to initialize the Kubernetes master.
  - **join-worker.sh**: Script for worker nodes to join the cluster.

- **providers.tf / versions.tf / variables.tf / outputs.tf**: Root stack config files.

## Prerequisites

- A Proxmox server with access to create virtual machines.
- Terraform installed on your local machine.
- OpenTofu installed as a Terraform alternative.

## Setup Instructions

1. **Clone the Repository**: 
   ```bash
   git clone <repository-url>
   cd k8s-build/proxmox
   ```

2. **Configure Variables**:
   Update `terraform.tfvars` with your desired Proxmox and VM settings.

3. **Initialize Terraform**: 
   Run the following command to initialize the Terraform configuration:
   ```bash
   tofu init
   ```

4. **Plan the Deployment**:
   Generate an execution plan to see what resources will be created:
   ```bash
   tofu plan
   ```

5. **Apply the Configuration**: 
   Deploy the Kubernetes cluster by applying the configuration:
   ```bash
   tofu apply
   ```

## How Split Approach Works

1. Terraform creates VMs and configures static IPs and user credentials.
2. `null_resource.kube_bootstrap` runs `scripts/bootstrap-k8s.sh`.
3. Script waits for SSH, installs containerd/kubeadm/kubelet/kubectl, initializes master, and joins workers.

This keeps VM provisioning and Kubernetes bootstrap loosely coupled and easier to debug.

## Usage

After the deployment is complete, you can access your Kubernetes cluster using `kubectl`. The master node's IP address will be outputted after the deployment.

## Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.

## License

This project is licensed under the MIT License.