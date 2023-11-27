terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.74.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.4.1"
    }
    google-beta = {
      version = "~> 3.84.0"
    }
  }

  required_version = ">= 0.14"
}
