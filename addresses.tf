resource "google_compute_address" "nginx_ingress_controller_ip" {
  name         = "${var.k8s_cluster_name}-nginx-ingress-controller"
  region       = var.k8s_cluster_region
  description  = "${var.k8s_cluster_name} nginx-ingress-controller IP"
  address_type = "EXTERNAL"
  project      = data.google_client_config.default.project
}
