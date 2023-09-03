# Infrastructure Configuration

This directory contains specification of the infrastructure used to run this
application on Google Cloud.

## Requirements

Infrastructure is specified using [Terraform](https://www.terraform.io/) you
will need to install the Terraform CLI before starting.

## Provisioning

Provisioning must be run in the following sequence and assumes you have a Google
Cloud Bucket available for use as the [Terraform
Backend](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).

Apply the Terraform configuration and additional documented README steps in the
following order:

1. [App Assets Cloud Bucket](./bucket/README.md)
2. [Google Artifact Registry Docker repository](./docker-repo/README.md)
3. [Google Cloud Run Instance](./cloud-run/README.md)
4. For CD GitHub action provide the service account key from step 3. as a GitHub
   action secret called `GOOGLE_CREDENTIAL`
