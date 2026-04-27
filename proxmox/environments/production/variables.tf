variable "master_vm_name" {
  description = "The name of the Kubernetes master VM"
  type        = string
  default     = "k8s-master"
}

variable "worker_vm_names" {
  description = "The names of the Kubernetes worker VMs"
  type        = list(string)
  default     = ["k8s-worker-1", "k8s-worker-2"]
}

variable "vm_memory" {
  description = "Memory allocated for each VM in MB"
  type        = number
  default     = 2048
}

variable "vm_cpu" {
  description = "Number of CPUs allocated for each VM"
  type        = number
  default     = 2
}

variable "network_bridge" {
  description = "The network bridge to use for the VMs"
  type        = string
  default     = "vmbr0"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to install"
  type        = string
  default     = "1.24.0"
}

variable "proxmox_server" {
  description = "The Proxmox server address"
  type        = string
}

variable "proxmox_user" {
  description = "The Proxmox user for authentication"
  type        = string
}

variable "proxmox_password" {
  description = "The Proxmox password for authentication"
  type        = string
  sensitive   = true
}