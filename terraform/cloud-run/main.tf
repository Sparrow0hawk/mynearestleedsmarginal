terraform {
  backend "gcs" {
    bucket = "mynearestleeds-tf-backend"
    prefix = "cloud-run"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_service_account" "cloud-run-service-act" {
  project      = var.project
  account_id   = "leeds-app-sa"
  display_name = "Cloud run service account"
}

locals {
  sa_roles = ["roles/iam.serviceAccountTokenCreator",
    "roles/artifactregistry.writer",
    "roles/run.developer",
    "roles/iam.serviceAccountUser"
  ]

  domains = [
    "www.mynearestleedsmarginal.com",
    "mynearestleedsmarginal.com"
  ]

  container_registry_url = "${var.region}-docker.pkg.dev/${var.project}/docker"
}

resource "google_project_iam_member" "project" {
  for_each = toset(local.sa_roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.cloud-run-service-act.email}"
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.cloud-run-service-act.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}


resource "google_cloud_run_service" "main-app" {
  name     = "mynearestleedsmarginal-deploy"
  location = var.region

  metadata {
    namespace = var.project
  }
  template {
    spec {
      containers {
        image = join("/", [local.container_registry_url, "mynearestleedsmarg:latest"])
        ports {
          container_port = 3838
        }
      }
      service_account_name = google_service_account.cloud-run-service-act.email
    }
  }
}


resource "google_cloud_run_domain_mapping" "default" {
  for_each = toset(local.domains)
  location = var.region
  name     = each.value

  metadata {
    namespace = var.project
  }

  spec {
    route_name = google_cloud_run_service.main-app.name
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
  location = google_cloud_run_service.main-app.location
  project  = google_cloud_run_service.main-app.project
  service  = google_cloud_run_service.main-app.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

data "google_storage_bucket" "app-assets" {
  name = "mynearestleeds-app-assets"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = data.google_storage_bucket.app-assets.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud-run-service-act.email}"
}
