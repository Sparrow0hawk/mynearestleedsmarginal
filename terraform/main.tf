# need cloud run
# artifact registry
# OIDC

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


resource "google_cloud_run_service" "default" {
  name     = "mynearestleedsmarginal-deploy"
  location = var.region

  metadata {
    namespace = var.project
  }
  template {
    spec {
    containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}

# add a iam policy to make app public
data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
