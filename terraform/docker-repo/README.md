# Docker Repository Terraform Config

This directory contains infrastructure for provisioning a Docker Artifact
Registry using Terraform.

## Provisioning

To create the docker repo:

1. Initialise the Terraform configuration:

    ```bash
    terraform init
    ```

2. Create the resources (type `yes` when prompted):

    ```
    terraform apply
    ```

## Pushing a Docker image

1. Log in to gcloud
    ```bash
    gcloud auth login
    ```

2. Configure authentication for our new artifact registry
    ```bash
    gcloud auth configure-docker europe-west1-docker.pkg.dev
    ```

3. Build a local copy of our app using Docker tagged to our artifact registry

    ```bash
    TAG_NAME=$(terraform output -raw docker_registry_url)/mynearestleedsmarg:latest

    docker build ../.. -f ../../dockerfiles/Dockerfile -t $TAG_NAME
    ```

4. Push the built container to Google Artifact Registry
    ```bash
    docker push $TAG_NAME
    ```
