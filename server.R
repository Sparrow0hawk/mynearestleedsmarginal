# server.R for studentmarginals2019
library(here)
source(here('marginal-mapper','marginal-mapper-functions.R'))
library(shiny)
library(leaflet)
library(googleway)
library(sp)
library(dplyr)
library(rgeos)


# loading basic environment data
load(here("src","data","environdata.Rdata"), envir=.GlobalEnv)

# specify data path
data_path <- here('src','data','target_data.csv')

# load targeting dataframe
targeting_data <- get_targeting(data_path)

# load geojson data for scottish wpc
sco_wpc_geo <- get_geojson()

# pull out required constituencies
target_geo <- sco_wpc_geo[match(targeting_data$constit_cd, sco_wpc_geo$PCON13CD),]

targeting_data <- targeting_data[match(target_geo$PCON13CD, targeting_data$constit_cd),]

# specify colours
polpartycol <- c('red','yellow')

pal <- colorFactor(palette = polpartycol,
                   levels(targeting_data[,"Party"]))

server <- function(input, output, session) {
  
  # pressing button on empty postcode input now creates map for centred leeds address
  # additional functionality would be to wildcard several leeds addresses aimed at under populated
  # key seats
  points <- eventReactive(input$go, {
    get_myGeo(postcode = input$postcode, geokey = key1)
  },
    ignoreNULL= TRUE)
  
  output$mymap <- renderLeaflet(
    {leafletOptions(maxZoom = 10)
    base_map(data = target_geo,
             dataframe = targeting_data,
             labels = sprintf(
               "<strong>%s</strong><br/>%s majority<br/>%s <br/> <a href=%s>Click for link to events</a>",
               targeting_data$CONSTITUENCY, 
               as.character(targeting_data$MAJORITY), 
               targeting_data$Party,
               as.character(targeting_data$Link.to.doc)
             ) %>% lapply(htmltools::HTML),
             category_field = 'Party',
             col_pal = pal
             )
    })
  
  observeEvent(input$go, {
    
    if (!is.null(points)) {
      
      distance_frame <- determine_dist(points, target_geo, targeting_data)
      
      # NEW SECTION RESOLVING PLOTTING CRASH FOR POSTCODES OUTSIDE OF LEEDS
      # pulls out the constituency of postcode entered
      if (0 %in% distance_frame[,"Distance from points"]){
        my_const <- filter(distance_frame,
                           distance_frame[,"Distance from points"] == 0)
        
        # creates a variable of inputted constituency
        my_const <- my_const$Constituency
      }else {
        my_const <- "Other"
      }
      
      # END OF NEW SECTION
      
      # arranges by distance (nearest first) key seats list 
      arranged.dist_frame <- arrange(distance_frame, 
                                     distance_frame[,"Distance from points"])
    
    output$mymap <- renderLeaflet({
      leaflet() %>%
        setView(lng = points()$results$geometry$location$lng,
                lat = points()$results$geometry$location$lat,
                zoom = 12) %>%
        addTiles() %>%
        addPolygons(data = target_geo,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(targeting_data$Party), 
                    fillOpacity=0.7,
                    weight = 2,
                    popup = sprintf(
                      "<strong>%s</strong><br/>%s majority<br/>%s <br/> <a href=%s>Click for link to events</a>",
                      targeting_data$CONSTITUENCY, 
                      as.character(targeting_data$MAJORITY), 
                      targeting_data$Party,
                      as.character(targeting_data$Link.to.doc)
                    ) %>% lapply(htmltools::HTML)
                    ) %>%
        addMarkers(data = points()$results$geometry$location)
    })
    
    
    output$value <- renderText({
      HTML(paste0("<div class='top-marg'>",
      "<strong>Your nearest 3 marginals are:</strong>",
      "<div>1. ",as.character(arranged.dist_frame$Constituency[1]),
      " - <a href=",as.character(arranged.dist_frame$Link.to.doc[1]),
      ">Click for a link to events here!</a></div>",
      "<div>2. ",as.character(arranged.dist_frame$Constituency[2]),
      " - <a href=",as.character(arranged.dist_frame$Link.to.doc[2]),
      ">Click for a link to events here!</a></div>",
      "<div>3. ",as.character(arranged.dist_frame$Constituency[3]),
      " - <a href=",as.character(arranged.dist_frame$Link.to.doc[3]),
      ">Click for a link to events here!</a></div></div>")
      )
      })
    
    }
    })
  
}

