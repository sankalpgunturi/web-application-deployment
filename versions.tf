terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.79.0, < 6"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.79.0, < 6"
    }
        kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.4.1"
    }
  }
  # GCP requires Terraform 0.14 or later
  required_version = ">= 0.14"  
}
