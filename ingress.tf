resource "helm_release" "nginx-ingress" {
  name          = "nginx-ingress"
  chart         = "stable/nginx-ingress"
  namespace     = "default"
  recreate_pods = true
  force_update  = true
  version       = "1.7.0"

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.nginx_ingress_controller_ip.address
  }

  set {
    name  = "controller.stats.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "false"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = "true"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = "9913"
  }

  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "default/${kubernetes_secret.acme-tls-monitoring.metadata[0].name}"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.config.client-max-body-size"
    value = "1024m"
  }

  set {
    name  = "controller.config.proxy-body-size"
    value = "1024m"
  }

  set_string {
    name  = "controller.config.proxy-read-timeout"
    value = "3600"
  }

  set_string {
    name  = "controller.config.proxy-connect-timeout"
    value = "3600"
  }

  set_string {
    name  = "controller.config.proxy-send-timeout"
    value = "3600"
  }

  set_string {
    name  = "controller.config.use-forwarded-headers"
    value = "True"
  }

  set_string {
    name  = "controller.config.ssl-redirect"
    value = "True"
  }

  set_string {
    name  = "controller.config.use-proxy-protocol"
    value = "false"
  }

  set {
    name  = "controller.config.proxy-real-ip-cidr"
    value = "0.0.0.0/0"
  }

  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "default/${kubernetes_secret.acme-tls-monitoring.metadata[0].name}"
  }
}
