variable "proxmox_api_url" {
  description = "The URL of the Proxmox API."
  type        = string
}

variable "proxmox_api_token" {
  description = "The API token for authenticating with the Proxmox server."
  type        = string
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

variable "vm_cpu" {
  description = "The number of CPUs for each VM."
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "The amount of memory (in MB) for each VM."
  type        = number
  default     = 2048
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