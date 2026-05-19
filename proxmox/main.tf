resource "proxmox_virtual_environment_vm" "k8s_master" {
  vm_id     = var.master_vmid
  name      = var.master_vm_name
  node_name = try(var.proxmox.node_name, var.proxmox_node)

  clone {
    vm_id = tonumber(try(var.proxmox.template_id, var.template_id))
  }

  cpu {
    cores = var.vm_cpu
    type  = "x86-64-v2-AES"
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
    type  = "x86-64-v2-AES"
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

# Automated Kubernetes installation
resource "null_resource" "kubernetes_install" {
  count = var.bootstrap_enabled ? 1 : 0

  depends_on = [
    proxmox_virtual_environment_vm.k8s_master,
    proxmox_virtual_environment_vm.k8s_worker
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for VMs to be ready..."
      bash ${path.module}/scripts/wait-for-vms.sh
      
      echo "Installing Kubernetes cluster..."
      bash ${path.module}/scripts/install-k8s.sh ${var.master_ip} ${var.worker_ips[0]} ${var.worker_ips[1]}
    EOT
  }

  triggers = {
    master_id  = proxmox_virtual_environment_vm.k8s_master.id
    worker_ids = join(",", proxmox_virtual_environment_vm.k8s_worker[*].id)
  }
}

output "master_ip" {
  value = var.master_ip
}

output "worker_ips" {
  value = var.worker_ips
}