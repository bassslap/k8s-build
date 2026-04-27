output "master_ip" {
  value = proxmox_vm.master.ip
}

output "worker_ips" {
  value = [for worker in proxmox_vm.workers : worker.ip]
}