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

resource "kubernetes_deployment" "web_application_deployment" {
  metadata {
    name = "web-application-deployment"
    labels = {
      App = "web-application-deployment"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "web-application-deployment"
      }
    }
    template {
      metadata {
        labels = {
          App = "web-application-deployment"
        }
      }
      spec {
        container {
          image = "sankalpgunturi/ready:latest"
          name  = "web-application-deployment"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web_application_service" {
  metadata {
    name = "web-application-lb"
  }
  spec {
    selector = {
      App = kubernetes_deployment.web_application_deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.web_application_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.web_application_cluster.master_auth.0.cluster_ca_certificate)
}
