variable "gke_num_nodes" {
  default     = 4
  description = "number of gke nodes"
}

data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

data "google_client_config" "default" {}

# Create a GKE cluster
resource "google_container_cluster" "web_application_cluster" {
  provider = google-beta
  name     = "web-application-cluster"
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "web_application_cluster_node_pool" {
  name       = google_container_cluster.web_application_cluster.name
  location   = var.region
  cluster    = google_container_cluster.web_application_cluster.name
  version = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
  node_count = var.gke_num_nodes

  autoscaling {
    min_node_count = 1
    max_node_count = 10
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

    labels = {
      env = var.project_id
    }

    machine_type = "n1-standard-4"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

locals {
  deployment_yaml = file("${path.module}/infra/deployment.yaml")
  service_yaml    = file("${path.module}/infra/service.yaml")

  decoded_deployment = yamldecode(local.deployment_yaml)
  decoded_service    = yamldecode(local.service_yaml)
}

resource "kubernetes_deployment" "web_application_deployment" {
  metadata {
    name = local.decoded_deployment.metadata.name
  }
  spec {
    replicas = local.decoded_deployment.spec.replicas
    selector {
      match_labels = local.decoded_deployment.spec.selector.matchLabels
    }
    template {
      metadata {
        labels = local.decoded_deployment.spec.template.metadata.labels
      }
      spec {
        container {
          image = local.decoded_deployment.spec.template.spec.containers[0].image
          name  = local.decoded_deployment.spec.template.spec.containers[0].name
        }
      }
    }
  }
}

resource "kubernetes_service" "web_application_service" {
  metadata {
    name = local.decoded_service.metadata.name
  }
  spec {
    selector = local.decoded_service.spec.selector
    port {
      port        = local.decoded_service.spec.ports[0].port
      target_port = local.decoded_service.spec.ports[0].targetPort
    }
    type = local.decoded_service.spec.type
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.web_application_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.web_application_cluster.master_auth.0.cluster_ca_certificate)
}
