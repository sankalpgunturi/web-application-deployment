variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "web-service-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "web-service-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name

  # Assigning IP CIDR range to subnet
  ip_cidr_range = "10.10.0.0/24"
}
