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

resource "google_artifact_registry_repository" "docker-repo" {
  location      = var.region
  repository_id = "docker"
  description   = "Docker container registry"
  format        = "DOCKER"
}
