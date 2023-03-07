terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.46.0"
    }
  }
}

provider "google" {
  project     = var.ecm_provider.project
  region      = var.ecm_provider.region
  zone        = var.ecm_provider.zone
  credentials = var.ecm_provider.credentials
}
