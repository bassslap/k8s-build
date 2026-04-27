output "master_ip" {
  value = module.proxmox-vm.master_ip
}

output "worker_ips" {
  value = module.proxmox-vm.worker_ips
}

output "kube_cluster_endpoint" {
  value = module.kube-bootstrap.cluster_endpoint
}

output "kube_nodes" {
  value = module.kube-bootstrap.node_info
}