# experiments creating a single map dataframe object
library(here)
library(sp)
library(rgdal)
library(leaflet)
source("R/utils.R")

incumbents_df1 <- read.csv("assets/data/mainfile_2020.csv", row.names = 1)

new_leeds_shp <- readOGR("assets/data/2021_leedswards.geojson")

names(new_leeds_shp)

# merging using sp

test_dat <- merge(new_leeds_shp, incumbents_df1, 
      by.x = 'WARD_NAME', 
      by.y = 'Ward')

polpartycol <- c('blue','black','green','red','orange','purple')

pal <- colorFactor(palette = polpartycol,
                   levels(as.factor(incumbents_df1$Description_2018)))

labels <- generate_ward_labels(test_dat)

labels

leaflet() %>%
  addTiles() %>%
  addPolygons(data = test_dat,
              stroke = TRUE,
              color = "black",
              fillColor = ~pal(test_dat$Description_2018),
              fillOpacity=0.3,
              dashArray = 5,
              weight = 2,
              group = "Wards",
              label = labels)


full_spatial_df <- merge(new_leeds_shp, incumbents_df1, 
                  by.x = 'WARD_NAME', 
                  by.y = 'Ward')

writeOGR(full_spatial_df, 
         "assets/data/2021_leeds_df1.geojson", 
         layer="meuse", 
         driver="GeoJSON")
