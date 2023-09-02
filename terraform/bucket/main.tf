terraform {
  backend "gcs" {
    bucket = "mynearestleeds-tf-backend"
    prefix = "main"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_storage_bucket" "app-assets" {
  name     = "mynearestleeds-app-assets"
  location = var.region
  project  = var.project

  public_access_prevention = "enforced"

  versioning {
    enabled = true
  }
  force_destroy = true
}
