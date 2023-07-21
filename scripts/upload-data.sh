#!/usr/bin/env bash

set -e

BUCKET_URL=$(terraform -chdir=terraform/ output -raw storage-bucket)

gsutil rsync assets/data $BUCKET_URL
