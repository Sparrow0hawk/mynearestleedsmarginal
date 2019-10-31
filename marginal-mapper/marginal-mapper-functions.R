# utility functions for studentmarginals2019
library(googleway)
library(here)
library(geojsonio)


# helper function
'%!in%' <- function(x,y)!('%in%'(x,y))


# load get geojson data 

get_geojson <- function() {
  # fetch geojson data from UK-geojson github
  
  sco_wpc_url <- "https://raw.githubusercontent.com/martinjc/UK-GeoJSON/master/json/electoral/sco/wpc.json"
  
  sco_wpc <- geojsonio::geojson_read(sco_wpc_url, what = 'sp')
  
  return(sco_wpc)
}

get_targeting <- function(data_path) {
  # test loading the targeting spreadsheet
  
  target_frame <- data.frame(read.csv(data_path))
  
  return(target_frame)
}

get_myGeo <- function(postcode, geokey) {
  
  points_dim <- google_geocode(as.character(postcode), key = geokey)
  
  return(points_dim)
}



