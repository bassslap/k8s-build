output "kubernetes_master_ip" {
  value = var.master_ip
}

output "kubernetes_worker_ips" {
  value = var.worker_ips
}

output "kubernetes_cluster_endpoint" {
  value = "https://${var.master_ip}:6443"
}

output "kubernetes_node_info" {
  value = {
    master  = proxmox_virtual_environment_vm.k8s_master.name
    workers = [for vm in proxmox_virtual_environment_vm.k8s_worker : vm.name]
  }
}