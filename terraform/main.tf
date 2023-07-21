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
  repository_id = join("", [var.project, "-ecr"])
  description   = "Docker container registry"
  format        = "DOCKER"
}


resource "google_cloud_run_v2_service" "default" {
  name     = "mynearestleedsmarginal-deploy"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = join("/", ["${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.docker-repo.repository_id}", "mynearestleedsmarg"])
      ports {
        container_port = 3838
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
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
