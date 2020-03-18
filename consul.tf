resource "helm_release" "consul" {
  name          = "consul"
  chart         = "stable/consul"
  namespace     = "default"
  recreate_pods = true
  force_update  = true

  set {
    name  = "Replicas"
    value = "3"
  }
  set {
    name  = "ImageTag"
    value = "1.7.2"
  }
}
