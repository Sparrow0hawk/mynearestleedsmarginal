# Install R version 3.5
FROM ghcr.io/sparrow0hawk/mynearestleedsmarginalbase:docker-base

COPY ../ /app

# Make the ShinyApp available at port 80
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
