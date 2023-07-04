
# create project in gcp
gcloud projects create test-cloud-run-iap --name="Test terra shiny"

# set current project with gcloud as this project
gcloud config set project test-cloud-run-iap

gcloud beta billing projects link test-cloud-run-iap \
 --billing-account $BILLING_ACCOUNT_ID

gcloud services enable \
    run.googleapis.com \
    iam.googleapis.com \
    artifactregistry.googleapis.com

gcloud iam service-accounts create terrashiny \
 --display-name "Terra shiny service account"

gcloud projects add-iam-policy-binding test-cloud-run-iap \
    --member="serviceAccount:terrashiny@test-cloud-run-iap.iam.gserviceaccount.com" \
    --role="roles/owner"

gcloud iam service-accounts keys create .credentials.json \
    --iam-account=terrashiny@test-cloud-run-iap.iam.gserviceaccount.com
