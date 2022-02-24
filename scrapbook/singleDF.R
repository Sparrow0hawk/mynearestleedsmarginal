#!/usr/bin/env Rscript

# create geojson object with data as features

library(here)
library(sp)
library(rgdal)
library(leaflet)
source("R/utils.R")

main <- function(majority_file, output_name, geojson=FALSE) {

      incumbents_df1 <- read.csv(majority_file, row.names = 1)

      new_leeds_shp <- readOGR(here("assets","data","leeds_wards_2018.geojson"))

      full_spatial_df <- merge(new_leeds_shp, incumbents_df1, 
                        by.x = 'WARD_NAME', 
                        by.y = 'Ward')

      if(isTRUE(geojson)){
            writeOGR(full_spatial_df, 
                  paste0("assets/data/",output_name,".geojson"), 
                  layer="meuse", 
                  driver="GeoJSON")
      }
      saveRDS(full_spatial_df,
              paste0("assets/data/",output_name,".Rdata")
              )
}

args <- commandArgs(trailingOnly = TRUE)

if(length(args) < 2){
  stop("Must provide arguments for path to majorities file and output file name")
} else {
  main(args[1], args[2], args[3])
}
