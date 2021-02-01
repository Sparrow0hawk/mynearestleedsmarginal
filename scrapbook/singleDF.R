# experiments creating a single map dataframe object

library(sp)


testBind <- cbind(shape_leeds, incumbents_df1)

# merging using sp

test_dat <- merge(shape_leeds, incumbents_df1, 
      by.x = 'WARD_NAME', 
      by.y = 'Ward')

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

### creating a single geojson object with all data

shape_leeds <- readOGR(here("assets","data","leedswards2018.geojson"))

# load 2020 main data
incumbents_df1 <- read.csv(here('assets','data','mainfile_2020.csv'),
                           row.names = 'X',
                           stringsAsFactors = FALSE)

full_spatial_df <- merge(shape_leeds, incumbents_df1, 
                  by.x = 'WARD_NAME', 
                  by.y = 'Ward')

writeOGR(full_spatial_df, "assets/data/2021_leeds_df.geojson", layer="meuse", driver="GeoJSON")
