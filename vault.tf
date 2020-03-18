data "helm_repository" "vault" {
  name = "incubator"
  url  = "https://kubernetes-charts-incubator.storage.googleapis.com"
}

resource "helm_release" "vault" {
  name          = "vault"
  chart         = "vault"
  repository    = data.helm_repository.vault.metadata[0].name
  namespace     = "default"
  recreate_pods = true
  force_update  = true
  version       = "0.23.5"

  set {
    name  = "replicaCount"
    value = "3"
  }
  set {
    name  = "consulAgent.tag"
    value = "1.7.2"
  }
  set {
    name  = "consulAgent.join"
    value = "consul.default.svc"
  }
  set {
    name  = "consulAgent.gossipKeySecretName"
    value = "consul-gossip-key"
  }
  # vault config
  set {
    name  = "vault.config.storage.consul.address"
    value = "127.0.0.1:8500"
  }
  set {
    name  = "vault.config.storage.consul.path"
    value = "vault"
  }
}
