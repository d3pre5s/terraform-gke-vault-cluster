terraform {
  required_version = ">= 0.12.7"
  backend "gcs" {
    bucket = "terraform-states-cluster"
    # name of bucket-file, i recommend to set it equal clustername
    # variables may not be used here
    prefix = "k01-gcp-dev"
  }
}

provider "google" {
  version = ">= 2.8.0"
  project = var.google_cloud_project
  region  = var.k8s_cluster_region
  zone    = var.k8s_cluster_zone
}

provider "google-beta" {
  version = "2.17.0"
  project = var.google_cloud_project
  region  = var.k8s_cluster_region
  zone    = var.k8s_cluster_zone
}

data "google_client_config" "default" {}

data "google_container_cluster" "k8s_cluster" {
  name = var.k8s_cluster_name
  zone = var.k8s_cluster_zone
}

provider "kubernetes" {
  version     = "1.8.1"
  config_path = "~/.kube/${var.k8s_cluster_name}"
}

provider "helm" {
  version         = "0.10.1"
  namespace       = "kube-system"
  service_account = "tiller"
  install_tiller  = true
  debug           = true
  max_history     = 100
  kubernetes {
    config_path = "~/.kube/${var.k8s_cluster_name}"
  }
}

provider "acme" {
  version    = "1.4.0"
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "random" {
  version = "2.2.1"
}

provider "tls" {
  version = "2.1.0"
}

provider "null" {
  version = "2.1.2"
}
