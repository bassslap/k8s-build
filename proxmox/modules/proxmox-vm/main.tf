resource "proxmox_vm_qemu" "k8s_master" {
  name        = "k8s-master"
  target_node = var.proxmox_node
  clone       = var.template_id
  cores       = var.master_cores
  memory      = var.master_memory
  net0        = "virtio,bridge=${var.network_bridge},ip=${var.master_ip},gw=${var.gateway}"
  
  cloudinit {
    user_data = file("${path.module}/../../templates/cloud-init-master.yaml")
  }
}

resource "proxmox_vm_qemu" "k8s_worker" {
  count       = var.worker_count
  name        = "k8s-worker-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = var.template_id
  cores       = var.worker_cores
  memory      = var.worker_memory
  net0        = "virtio,bridge=${var.network_bridge},ip=${element(var.worker_ips, count.index)},gw=${var.gateway}"
  
  cloudinit {
    user_data = file("${path.module}/../../templates/cloud-init-worker.yaml")
  }
}

output "master_ip" {
  value = proxmox_vm_qemu.k8s_master.ip
}

output "worker_ips" {
  value = [for w in proxmox_vm_qemu.k8s_worker : w.ip]
}