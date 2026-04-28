provider "proxmox" {
  endpoint  = try(var.proxmox.endpoint, "https://${var.proxmox_host}:8006")
  api_token = try(var.proxmox.api_token_id, "${var.api_user}!${var.api_token_name}") != "" ? "${try(var.proxmox.api_token_id, "${var.api_user}!${var.api_token_name}")}=${try(var.proxmox.api_token_secret, var.api_token_value)}" : var.proxmox_api_token
  insecure  = true

  ssh {
    agent       = true
    username    = "root"
    private_key = file("~/.ssh/id_rsa")
  }
}