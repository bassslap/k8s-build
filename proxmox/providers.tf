provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true
}

provider "kubernetes" {
  host                   = module.kube-bootstrap.kubeconfig["host"]
  token                  = module.kube-bootstrap.kubeconfig["token"]
  cluster_ca_certificate = base64decode(module.kube-bootstrap.kubeconfig["cluster_ca_certificate"])
}