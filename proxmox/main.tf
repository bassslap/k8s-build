resource "proxmox_vm_qemu" "k8s_master" {
  name        = "k8s-master"
  target_node = "proxmox-node"
  clone       = "ubuntu24-template-9001"
  cores       = 2
  memory      = 2048
  net0        = "virtio,bridge=vmbr0"
  ipconfig0   = "ip=dhcp"
  sshkeys     = file("~/.ssh/id_rsa.pub")

  cloudinit {
    user_data = templatefile("${path.module}/../templates/cloud-init-master.yaml", {})
  }
}

resource "proxmox_vm_qemu" "k8s_worker" {
  count       = 2
  name        = "k8s-worker-${count.index + 1}"
  target_node = "proxmox-node"
  clone       = "ubuntu24-template-9001"
  cores       = 2
  memory      = 2048
  net0        = "virtio,bridge=vmbr0"
  ipconfig0   = "ip=dhcp"
  sshkeys     = file("~/.ssh/id_rsa.pub")

  cloudinit {
    user_data = templatefile("${path.module}/../templates/cloud-init-worker.yaml", {})
  }
}

output "master_ip" {
  value = proxmox_vm_qemu.k8s_master.ip
}

output "worker_ips" {
  value = [for vm in proxmox_vm_qemu.k8s_worker : vm.ip]
}