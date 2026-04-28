variable "proxmox_api_url" {
  description = "The URL of the Proxmox API."
  type        = string
  default     = ""
}

variable "proxmox_api_token" {
  description = "The API token for authenticating with the Proxmox server."
  type        = string
  default     = ""
}

variable "proxmox" {
  description = "Optional Proxmox settings object compatible with external tfvars layouts."
  type        = any
  default     = {}
}

variable "proxmox_host" {
  description = "Proxmox host/IP used to construct the API endpoint."
  type        = string
  default     = "10.100.0.10"
}

variable "api_user" {
  description = "Proxmox API user, for example terraform@pve."
  type        = string
  default     = "terraform@pve"
}

variable "api_token_name" {
  description = "Proxmox API token name."
  type        = string
  default     = "chef"
}

variable "api_token_value" {
  description = "Proxmox API token secret value."
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_node" {
  description = "Proxmox node name where VMs will be created."
  type        = string
  default     = "pve"
}

variable "public_key_file" {
  description = "Path to the SSH public key for VM access."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "template_id" {
  description = "Template VM ID used for cloning."
  type        = number
  default     = 9001
}

variable "vm_template" {
  description = "The template to use for creating VMs."
  type        = string
  default     = "ubuntu24"
}

variable "master_vm_name" {
  description = "The name of the Kubernetes master VM."
  type        = string
  default     = "k8s-master"
}

variable "worker_vm_names" {
  description = "The names of the Kubernetes worker VMs."
  type        = list(string)
  default     = ["k8s-worker-1", "k8s-worker-2"]
}

variable "master_ip" {
  description = "Static IPv4 address for the Kubernetes master node."
  type        = string
  default     = "10.100.1.101"
}

variable "worker_ips" {
  description = "Static IPv4 addresses for the Kubernetes worker nodes."
  type        = list(string)
  default     = ["10.100.1.102", "10.100.1.103"]
}

variable "gateway" {
  description = "Default IPv4 gateway for the VM subnet."
  type        = string
  default     = "10.100.1.1"
}

variable "dns_servers" {
  description = "DNS servers configured in cloud-init networking."
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "master_vmid" {
  description = "Explicit VM ID for the Kubernetes master node."
  type        = number
  default     = 251
}

variable "worker_vmids" {
  description = "Explicit VM IDs for the Kubernetes worker nodes."
  type        = list(number)
  default     = [252, 253]
}

variable "vm_cpu" {
  description = "The number of CPUs for each VM."
  type        = number
  default     = 8
}

variable "vm_memory" {
  description = "The amount of memory (in MB) for each VM."
  type        = number
  default     = 16384
}

variable "vm_disk_size" {
  description = "The size of the disk (in GB) for each VM."
  type        = number
  default     = 20
}

variable "network_bridge" {
  description = "The network bridge to use for the VMs."
  type        = string
  default     = "vmbr0"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to install."
  type        = string
  default     = "1.24.0"
}

variable "pod_network_cidr" {
  description = "Pod network CIDR used by kubeadm init."
  type        = string
  default     = "10.244.0.0/16"
}

variable "ssh_username" {
  description = "SSH username used for post-provision Kubernetes bootstrap."
  type        = string
  default     = "ubuntu"
}

variable "ssh_private_key_file" {
  description = "Private key path used for SSH-based bootstrap."
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "vm_user_password" {
  description = "Password set for the VM user account (for console login)."
  type        = string
  sensitive   = true
  default     = "ubuntu123!"
}

variable "bootstrap_enabled" {
  description = "Enable automatic Kubernetes bootstrap after VM creation (deprecated - use cloud-init instead)."
  type        = bool
  default     = false
}