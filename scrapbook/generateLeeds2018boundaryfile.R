# loading new ward shapefile for 2018 boundaries
library(sp)
library(rgdal)
library(leaflet)

download.file("https://opendata.arcgis.com/datasets/1cc7a2cd2e6045f6b7f140835512b1e3_0.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D",
              "assets/data/Wards__December_2020__UK_BFC_V2-shp.zip")

unzip("assets/data/Wards__December_2020__UK_BFC_V2-shp.zip",
      exdir = "assets/data/")

# load in new shapefile
new_shape <- readOGR(dsn = "assets/data/",
        layer = "Wards__December_2020__UK_BFC_V2",
        verbose = TRUE)

# load in leeds ward list
ward.list <- read.csv("assets/data/allwardlist.csv", header = F)

# substitute "and" for the amphersand character in leeds ward list
ward.listamph <- gsub("and", "&", ward.list$V1)

# get rough idea of number of ward names matching 
sum(new_shape$WD20NM %in% ward.listamph)

# select out only wards which share names with Leeds ward names
new_leeds_shp <- new_shape[new_shape$WD20NM %in% ward.listamph,]

# get leeds lat and lon
leeds_lat <- 53.801277

leeds_lon <- -1.548567

# select out only shape files wiith a lat difference to centre of leeds
# greater than 1
new_leeds_shp <- new_leeds_shp[1 > (leeds_lat - new_leeds_shp$LAT),]

# reproject data
new_leeds_shp <- spTransform(new_leeds_shp, CRS("+init=epsg:4269"))

# render file in leaflet to check
leaflet() %>%
  addPolygons(data = new_leeds_shp) %>%
  addTiles()

# rename ward name column to WARD_NAMES
names(new_leeds_shp)[3] <- c("WARD_NAME")

# replace amphersand with and
new_leeds_shp$WARD_NAME <- gsub("&", "and", new_leeds_shp$WARD_NAME)

# write out file to disk
writeOGR(new_leeds_shp, 
         "assets/data/2021_leedswards.geojson", 
         layer="meuse", driver="GeoJSON")

