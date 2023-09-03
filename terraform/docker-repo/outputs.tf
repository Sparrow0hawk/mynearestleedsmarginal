output "docker_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.docker-repo.repository_id}"
}
