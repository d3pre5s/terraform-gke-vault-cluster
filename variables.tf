variable "k8s_cluster_domain" {
  description = "The internal Kubernetes cluster domain	"
}

variable "k8s_cluster_name" {
  description = "The internal Kubernetes cluster name"
}

variable "k8s_cluster_region" {
  default = "europe-west2"
}

variable "k8s_cluster_zone" {
  default = "europe-west2-a"
}

variable "k8s_project_namespace" {
  description = "The default namespace"
}

variable "google_cloud_project" {
  description = "The GCP default project"
}

variable "dns_zone" {}

variable "k8s_cluster_network" {}
variable "k8s_cluster_subnetwork" {}
