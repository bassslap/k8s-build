# Kubernetes on Proxmox with OpenTofu

This project automates the deployment of a Kubernetes cluster on a Proxmox server using OpenTofu. It provisions a Kubernetes master node and two worker nodes using Terraform.

## Project Structure

- **modules/**: Contains reusable Terraform modules.
  - **proxmox-vm/**: Module for creating virtual machines on Proxmox.
  - **kube-bootstrap/**: Module for bootstrapping the Kubernetes cluster.

- **environments/**: Contains environment-specific configurations.
  - **production/**: Configuration for the production environment.

- **templates/**: Contains cloud-init templates for initializing the VMs.
  - **cloud-init-master.yaml**: Cloud-init configuration for the master node.
  - **cloud-init-worker.yaml**: Cloud-init configuration for the worker nodes.

- **scripts/**: Contains scripts for initializing the master and joining worker nodes.
  - **init-master.sh**: Script to initialize the Kubernetes master.
  - **join-worker.sh**: Script for worker nodes to join the cluster.

- **providers.tf**: Specifies the providers used in the Terraform configuration.

- **versions.tf**: Defines the required Terraform and provider versions.

- **variables.tf**: Contains global input variables for the project.

- **main.tf**: Entry point for the Terraform configuration.

- **outputs.tf**: Specifies the overall outputs for the project.

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
   Update the `environments/production/tofu.tfvars` file with your desired configurations, including VM specifications and network settings.

3. **Initialize Terraform**: 
   Run the following command to initialize the Terraform configuration:
   ```bash
   tofu init
   ```

4. **Plan the Deployment**: 
   Generate an execution plan to see what resources will be created:
   ```bash
   tofu plan -var-file=environments/production/tofu.tfvars
   ```

5. **Apply the Configuration**: 
   Deploy the Kubernetes cluster by applying the configuration:
   ```bash
   tofu apply -var-file=environments/production/tofu.tfvars
   ```

## Usage

After the deployment is complete, you can access your Kubernetes cluster using `kubectl`. The master node's IP address will be outputted after the deployment.

## Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.

## License

This project is licensed under the MIT License.