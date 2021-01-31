# mynearestleedsmarginal Shiny app

This is the [mynearestleedsmarginal app](https://mynearestleedsmarginal.com).

Inspired by Momentum's 2017 [mynearestmarginal.com](https://mynearestmarginal.com/), this project is an R Shiny applications that identifies your nearest marginal council ward in Leeds local authority.

## Docker container

If you have [Docker](https://www.docker.com/) installed this app can be built into a Docker container using the command:

```bash
cd mynearestleedsmarginal2019/

docker build -t mynearestleedsmarg .
```

You can run the container with the command:

```bash
docker run --rm -p 3838:3838 mynearestleedsmarg
```

With the container running you can navigate to `localhost:3838` in a web browser to view/interact with the app.

### Deploying to Google Cloud Run

You can deploy this app to Google Cloud with a properly configured [gcloud SDK](https://cloud.google.com/sdk/docs/install) using the following commands:

```bash
# submit the docker container to your private google cloud container registry
gcloud builds submit --tag gcr.io/$(gcloud config get-value project)/mynearestleedsmarg --timeout=60m

# deploy the container image to google cloud run
gcloud run deploy --image gcr.io/leeds-app-2-serverless/mynearestleedsmarg --platform managed --port=3838
```
