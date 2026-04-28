// Legacy file: root stack in ../../main.tf is the active split-approach deployment path.
// This file is retained for reference only and uses older resource/provider patterns.

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
    user_data = file("${path.module}/../../templates/cloud-init-master.yaml")
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
    user_data = file("${path.module}/../../templates/cloud-init-worker.yaml")
  }
}

output "master_ip" {
  value = proxmox_vm_qemu.k8s_master.ip
}

output "worker_ips" {
  value = [for w in proxmox_vm_qemu.k8s_worker : w.ip]
}

module "kube_bootstrap" {
  source = "../../modules/kube-bootstrap"

  master_ip = proxmox_vm_qemu.k8s_master.ip
  worker_ips = [for w in proxmox_vm_qemu.k8s_worker : w.ip]
}