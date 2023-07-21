#!/usr/bin/env bash

set -e

PROJECT=mynearestleedsmarginal-prod

# create project in gcp
#gcloud projects create $PROJECT --name="mynearestleedsmarg web app"

# set current project with gcloud as this project
#gcloud config set project $PROJECT

gcloud beta billing projects link $PROJECT \
 --billing-account $BILLING_ACCOUNT_ID

gcloud services enable \
    run.googleapis.com \
    iam.googleapis.com \
    artifactregistry.googleapis.com

