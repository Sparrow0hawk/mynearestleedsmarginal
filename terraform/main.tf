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

resource "google_service_account" "cloud-run-service-act" {
  project      = var.project
  account_id   = "leeds-app-sa"
  display_name = "Cloud run service account"
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.cloud-run-service-act.name
  public_key_type    = "TYPE_X509_PEM_FILE"
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
      service_account_name = google_service_account.cloud-run-service-act.email
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
