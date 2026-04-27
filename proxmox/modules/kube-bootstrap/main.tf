resource "null_resource" "kube_bootstrap" {
  provisioner "local-exec" {
    command = <<EOT
      # Initialize Kubernetes master
      bash ../scripts/init-master.sh

      # Join worker nodes to the cluster
      for i in range(1, var.worker_count + 1) {
        bash ../scripts/join-worker.sh ${i}
      }
    EOT
  }
}

output "kube_master_ip" {
  value = null_resource.kube_bootstrap.*.ip
}

output "kube_worker_ips" {
  value = null_resource.kube_bootstrap.*.worker_ips
}