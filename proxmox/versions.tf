terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.10"
    }
  }

  required_version = ">= 1.0.0"
}