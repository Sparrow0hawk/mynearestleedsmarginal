# loading geojson with rgdal is very slow
# lets save it as a Rdata file and load that instead

library(rgdal)
library(here)

shape_leeds <- readOGR(here("assets","data","2021_leeds_df1.geojson"))

saveRDS(shape_leeds, here('assets','data','2021geojson.Rdata'))
