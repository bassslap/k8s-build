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

variable "vm_disk_size" {
  description = "Disk size for each VM in GB"
  type        = number
  default     = 20
}

variable "network_bridge" {
  description = "The network bridge to use for the VMs"
  type        = string
  default     = "vmbr0"
}

variable "ip_addresses" {
  description = "Static IP addresses for the VMs"
  type        = list(string)
  default     = ["192.168.1.10", "192.168.1.11", "192.168.1.12"]
}

variable "proxmox_api_url" {
  description = "The URL of the Proxmox API"
  type        = string
}

variable "proxmox_api_token" {
  description = "The API token for Proxmox authentication"
  type        = string
}