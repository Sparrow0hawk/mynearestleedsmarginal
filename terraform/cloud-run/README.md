# Cloud Run Terraform Config

This directory contains infrastructure for provisioning a Cloud Run service with
domain mapping.

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

## Notes on Domain Mapping

- Domain mapping may succeed in the terraform apply step but still take some
  time to fully come into effect
