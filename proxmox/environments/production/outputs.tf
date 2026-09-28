output "master_ip" {
  value = proxmox_vm_qemu.k8s_master.ip
}

output "worker_ips" {
  value = [for worker in proxmox_vm_qemu.k8s_worker : worker.ip]
}

output "kube_cluster_endpoint" {
  value = "https://${proxmox_vm_qemu.k8s_master.ip}:6443"
}

output "kube_nodes" {
  value = concat(
    [proxmox_vm_qemu.k8s_master.ip],
    [for worker in proxmox_vm_qemu.k8s_worker : worker.ip]
  )
}