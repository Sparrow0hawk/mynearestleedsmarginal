# utility functions for studentmarginals2019
library(googleway)
library(here)
library(rgeos)
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

determine_dist <- function(points_lst, wpc_geo, target_data) {
  
  points_a <- cbind(lon = points_lst$results$geometry$location$lng, 
                    lat = points_lst$results$geometry$location$lat)
  
  points_sp <- SpatialPoints(points_a)
  
  points_df <- data.frame(apply(gDistance(points_sp, 
                                          wpc_geo, 
                                          byid = TRUE), 1, min))
  
  combined_dist_data <- cbind(target_data, points_df)
  
  names(combined_dist_data) <- c("Constituency",   #1
                             "MAJORITY",  #2
                             "Link.to.doc", #3
                             "Target.Hold", #4
                             "Labour.club",  #5
                             "Distance from points")  #6
  return(combined_dist_data)
}

