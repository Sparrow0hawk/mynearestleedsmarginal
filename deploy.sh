#!/usr/bin/env bash

DATE=$(date +"%Y-%m-%d")

PROJECT=$(gcloud config get-value project)

docker build . -f dockerfiles/Dockerfile -t mynearestleedsmarg:$DATE

docker tag mynearestleedsmarg:$DATE gcr.io/$PROJECT/mynearestleedsmarg:$DATE

docker push gcr.io/$PROJECT/mynearestleedsmarg:$DATE

gcloud run deploy mynearestleedsmarg-deploy \
                  --image gcr.io/leeds-app-2-serverless/mynearestleedsmarg:$DATE \
                  --region "europe-west1"
                  --platform managed \
                  --port=3838 \

 