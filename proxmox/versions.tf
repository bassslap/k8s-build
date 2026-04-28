terraform {
  required_version = ">= 1.3"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.1"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}