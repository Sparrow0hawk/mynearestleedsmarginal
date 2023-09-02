output "app-url" {
  value = google_cloud_run_service.main-app.status[0].url
}

output "service-account-key" {
  value     = google_service_account_key.mykey.private_key
  sensitive = true
}

output "service-account-email" {
  value = google_service_account.cloud-run-service-act.email
}
