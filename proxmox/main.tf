resource "proxmox_virtual_environment_vm" "k8s_master" {
  vm_id     = var.master_vmid
  name      = var.master_vm_name
  node_name = try(var.proxmox.node_name, var.proxmox_node)

  clone {
    vm_id = tonumber(try(var.proxmox.template_id, var.template_id))
  }

  cpu {
    cores = var.vm_cpu
  }

  memory {
    dedicated = var.vm_memory
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.master_ip}/14"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = "ubuntu"
      password = var.vm_user_password
      keys     = [trimspace(file(try(var.proxmox.public_key_file, var.public_key_file)))]
    }
  }
}

resource "proxmox_virtual_environment_vm" "k8s_worker" {
  count     = length(var.worker_vm_names)
  vm_id     = var.worker_vmids[count.index]
  name      = var.worker_vm_names[count.index]
  node_name = try(var.proxmox.node_name, var.proxmox_node)

  clone {
    vm_id = tonumber(try(var.proxmox.template_id, var.template_id))
  }

  cpu {
    cores = var.vm_cpu
  }

  memory {
    dedicated = var.vm_memory
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/14"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = "ubuntu"
      password = var.vm_user_password
      keys     = [trimspace(file(try(var.proxmox.public_key_file, var.public_key_file)))]
    }
  }
}

output "master_ip" {
  value = var.master_ip
}

output "worker_ips" {
  value = var.worker_ips
}