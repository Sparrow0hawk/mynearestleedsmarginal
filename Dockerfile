# Install R version 3.5
FROM rocker/shiny:latest

# Install Ubuntu packages
RUN apt-get update && apt-get --no-install-recommends install -y \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    xtail \
    libjq-dev \
    libgeos-dev \
    libgdal-dev


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean


# Copy configuration files into the Docker image
COPY ./app /app
COPY ./renv.lock ./renv.lock

# install renv & restore packages
RUN Rscript -e 'install.packages("renv")'
RUN Rscript -e 'renv::restore()'

# Make the ShinyApp available at port 80
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]