output "kube_master_ip" {
  value = module.proxmox-vm.master_ip
}

output "kube_worker_ips" {
  value = module.proxmox-vm.worker_ips
}

output "kube_cluster_endpoint" {
  value = "https://${module.proxmox-vm.master_ip}:6443"
}

output "kube_version" {
  value = var.kube_version
}