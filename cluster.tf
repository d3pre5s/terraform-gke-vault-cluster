resource "random_id" "cluster_name_suffix" {
  byte_length = 4
}

resource "google_container_node_pool" "k8s_cluster_node_pool" {
  provider   = google-beta
  node_count = 1
  name       = "${var.k8s_cluster_name}-k8s-${random_id.cluster_name_suffix.hex}"
  cluster    = google_container_cluster.k8s_cluster.name
  location   = var.k8s_cluster_zone
  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_config {
    disk_size_gb      = 20
    disk_type         = "pd-standard"
    image_type        = "COS"
    local_ssd_count   = 0
    machine_type      = "n1-standard-4"
    guest_accelerator = []
    metadata = {
      "disable-legacy-endpoints" = "true"
    }
    min_cpu_platform = "Automatic"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
    service_account = "default"
    tags            = []
    labels = {
      "node-role.kubernetes.io" = var.k8s_project_namespace
    }
  }
}

resource "google_container_cluster" "k8s_cluster" {
  provider                    = google-beta
  initial_node_count          = 1
  remove_default_node_pool    = true
  name                        = var.k8s_cluster_name
  location                    = var.k8s_cluster_zone
  enable_binary_authorization = false
  enable_intranode_visibility = false
  enable_kubernetes_alpha     = false
  enable_legacy_abac          = false
  enable_tpu                  = false

  logging_service    = "logging.googleapis.com"
  monitoring_service = "monitoring.googleapis.com"

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

  cluster_ipv4_cidr = var.k8s_cluster_network

  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  cluster_autoscaling {
    enabled = false
  }

  network_policy {
    enabled  = false
    provider = "PROVIDER_UNSPECIFIED"
  }
}

resource "google_compute_network" "network" {
  name                    = "network" 
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "dev-gblnd11-z01-k01-vms"
  ip_cidr_range = var.k8s_cluster_subnetwork
  network       = google_compute_network.network.self_link
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller-admin" {
  metadata {
    name = "tiller-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }
}
