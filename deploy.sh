#!/usr/bin/env bash

VER="2023-01"

PROJECT=$(gcloud config get-value project)

docker build . -f dockerfiles/Dockerfile -t mynearestleedsmarg:$VER

docker tag mynearestleedsmarg:$VER gcr.io/$PROJECT/mynearestleedsmarg:$VER

docker push gcr.io/$PROJECT/mynearestleedsmarg:$VER

gcloud run deploy mynearestleedsmarg-deploy \
                  --image gcr.io/leeds-app-2-serverless/mynearestleedsmarg:$VER \
                  --region "europe-west1" \
                  --platform managed \
                  --port=3838 

 