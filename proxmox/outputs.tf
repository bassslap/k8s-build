output "kubernetes_master_ip" {
  value = module.proxmox-vm.master_ip
}

output "kubernetes_worker_ips" {
  value = module.proxmox-vm.worker_ips
}

output "kubernetes_cluster_endpoint" {
  value = module.kube-bootstrap.cluster_endpoint
}

output "kubernetes_node_info" {
  value = module.kube-bootstrap.node_info
}