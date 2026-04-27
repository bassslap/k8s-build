variable "k8s_master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
  default     = 1
}

variable "k8s_worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 2
}

variable "k8s_version" {
  description = "Kubernetes version to install"
  type        = string
  default     = "1.24.0"
}

variable "network_cidr" {
  description = "CIDR block for the Kubernetes network"
  type        = string
  default     = "10.244.0.0/16"
}

variable "pod_network_cidr" {
  description = "CIDR block for the pod network"
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_network_cidr" {
  description = "CIDR block for the service network"
  type        = string
  default     = "10.96.0.0/12"
}

variable "k8s_api_port" {
  description = "Port for the Kubernetes API server"
  type        = number
  default     = 6443
}