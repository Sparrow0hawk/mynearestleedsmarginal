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

locals {
  sa_roles = ["roles/iam.serviceAccountTokenCreator",
    "roles/artifactregistry.writer",
    "roles/run.developer"
  ]
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

# need to resolve errors around verification
# resource "google_cloud_run_domain_mapping" "default" {
#   location = var.region
#   name     = "mynearestleedsmarginal.com"

#   metadata {
#     namespace = var.project
#   }

#   spec {
#     route_name = google_cloud_run_service.default.name
#   }
# }

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

resource "google_storage_bucket" "main" {
  name     = "mynearestleeds-app-assets"
  location = var.region
  project  = var.project

  public_access_prevention = "enforced"

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud-run-service-act.email}"
}
