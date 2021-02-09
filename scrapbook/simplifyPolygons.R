# simplify leeds geojson file
library(here)
library(sp)
library(rgeos)
library(rgdal)
library(leaflet)

shape_leeds <- readOGR(here("assets","data","2021_leeds_df1.geojson"))

simp_shp <- gSimplify(shape_leeds, tol = 0.001)

leaflet() %>%
  addPolygons(data = simp_shp) %>%
  addTiles()

simp_shp <- as(simp_shp, "SpatialPolygonsDataFrame")

writeOGR(simp_shp, 
         "assets/data/2021_leeds_df2.geojson", 
         layer="meuse", 
         driver="GeoJSON")
