# Install R version 3.5
FROM r-base:3.4.4

# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libssl-dev \
    xtail \
    libjq-dev \
    libgeos-dev \
    libgdal-dev

# Download and install ShinyServer (latest version)
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

# Install R packages that are required
# TODO: add further package if you need!
RUN R -e "install.packages(c('shiny', 'here','leaflet','googleway','sp','dplyr','rgeos','rmarkdown'), repos='http://cran.rstudio.com/')"
# installing rgdal from source
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/rgdal/rgdal_1.4-4.tar.gz', repos=NULL, type='source')"

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY . /srv/shiny-server/

# Make the ShinyApp available at port 80
EXPOSE 3838

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]