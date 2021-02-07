# server.R for mynearestleedsmarginal.com
library(shiny)
library(here)
library(leaflet)
library(googleway)
library(sp)
# not needed loading data
library(dplyr)
library(rgeos)
library(rgdal)
source(here('R','utils.R'))
options(shiny.sanitize.errors = TRUE)

# load all preparaed data
# gives magic number error
#load(here("assets","data","geodata.Rdata"), envir=.GlobalEnv)

shape_leeds <- readOGR(here("assets","data","2021_leeds_df.geojson"))

lst <- read.csv(here("assets","data","sampleloc.csv"), row.names = "X")

dialogue.link <- "https://dialogue.labour.org.uk/campaign/1?ons_code="

shape_leeds <- cbind(shape_leeds, paste0(dialogue.link, shape_leeds$WARD_CODE))

names(shape_leeds)[length(names(shape_leeds))] <- c("Dialogue.link")

# load googleways key file
key1 <- read.csv(here("assets","data","googleways_key.txt"),
                 row.names = 'X',
                 stringsAsFactors = FALSE)[[1]]

# load key seats list
if( file.exists(here("assets","data","keyseatlist.csv"))) {

  keyseats <- as.character(
    read.csv(
      here("assets","data","keyseatlist.csv"), header=FALSE)$V1
    )

} else {

  keyseats <- as.character(
    read.csv(
      here("assets","data","allwardlist.csv"), header=FALSE)$V1
  )
}

# load emails list
if( file.exists(here("assets","data","emails2020.csv"))) {

  emailstbl <- read.csv(
    here("assets","data","emails2020.csv"),
    encoding = "latin", header=FALSE)

} else {

  emailstbl <- read.csv(
    here("assets","data","emailblank.csv"),
    encoding = "latin", header=FALSE)
}

# load colours
polpartycol <- c('blue','black','green','red','orange','purple')

# set emails column names
names(emailstbl) <- c("Ward","Email")

# join emails to main dataframe
shape_leeds <-  merge(shape_leeds, emailstbl, 
                         by.x = 'WARD_NAME', 
                         by.y = 'Ward')



server <- function(input, output, session) {

  pal <- colorFactor(palette = polpartycol,
                     levels(as.factor(shape_leeds$Description_2018)))

  labels <- generate_ward_labels(shape_leeds)

  # pressing button on empty postcode input now creates map for centred leeds address
  # additional functionality would be to wildcard several leeds addresses aimed at under populated
  # key seats
  points <- eventReactive(input$go, {
    if (input$postcode == ""){
      a <- google_geocode(as.character(lst[sample(c(1,2,3), size=1),]), key = key1)
    } else
      a <- google_geocode(as.character(input$postcode), key = key1)},
    ignoreNULL= TRUE)

  output$mymap <- renderLeaflet({
    leafletOptions(maxZoom = 10)
    leaflet() %>%
      addTiles() %>%
      addPolygons(data = shape_leeds,
                  stroke = TRUE,
                  color = "black",
                  fillColor = ~pal(shape_leeds$Description_2018),
                  fillOpacity=0.3,
                  dashArray = 5,
                  weight = 2,
                  group = "Wards",
                  label = labels)
  })

  observeEvent(input$go, {

    if (!is.null(points)) {

      points_a <- cbind(lon = points()$results$geometry$location$lng, lat = points()$results$geometry$location$lat)

      points_sp <- SpatialPoints(points_a)

      points_df <- data.frame(apply(gDistance(points_sp, shape_leeds, byid = TRUE),1,min))

      target_ward <- cbind(shape_leeds,points_df)

      # rename the last column with distances 
      # this creates a warning i'd like to resolve
      names(target_ward)[length(names(target_ward))] <- c("Distance.from.points")

      # NEW SECTION RESOLVING PLOTTING CRASH FOR POSTCODES OUTSIDE OF LEEDS
      # pulls out the constituency of postcode entered
      if (0 %in% target_ward$Distance.from.points){
        my_const <- target_ward[target_ward$Distance.from.points == 0,]$Constituency

      }else {
        my_const <- "Other"
      }
      # END OF NEW SECTION

      # filter list for only key seat list
      # REMOVED FOR 2019 pending recommendations
      target_ward <- target_ward[target_ward$WARD_NAME %in% keyseats,]

      # checks whether inputted postcode constituency is present in
      # key seats list, to ensure within constituency filter
      if(my_const %in% target_ward$Constituency){
        target_ward <- target_ward[target_ward$Constituency %in% my_const,]
      }

      # arranges by distance (nearest first) key seats list
      # take the top item
      target_ward <- target_ward[order(target_ward@data$Distance.from.points) == 1,]

      # generate labels using the 1st row of the filtered dataframe
      labels1 <- generate_ward_labels(target_ward)
    }

    output$mymap <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = target_ward,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(target_ward$Description_2018),
                    fillOpacity=0.7,
                    weight = 2,
                    label = labels1) %>%
        addMarkers(data = points()$results$geometry$location)
    })


    output$value <- renderText({
      HTML(paste0("<div class='result-top-box'>",
      "Your nearest marginal is ",
      as.character(target_ward$WARD_NAME[1]),'</div>'))
      })

    if (is.na(target_ward$Email[1])){
      output$link1 <- renderUI({return_results_box(paste0(
        return_injectedButton(return_eventlink_html(target_ward)),
        return_injectedButton(return_dialoguelink_html(target_ward))
      )
      })
      
    } else {
      output$link1 <- renderUI({
        return_results_box(paste0(
        return_injectedButton(return_eventlink_html(target_ward)),
        return_injectedButton(return_email_html(target_ward)),
        return_injectedButton(return_dialoguelink_html(target_ward))
        )
      )
      })
    }
    })

  # added for map refresh button
  observeEvent(input$refresher_map, {

    output$mymap <- renderLeaflet({
      leafletOptions(maxZoom = 10)
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = shape_leeds,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(shape_leeds$Description_2018),
                    fillOpacity=0.3,
                    dashArray = 5,
                    weight = 2,
                    group = "Wards",
                    label = labels)
    })

    # clear text box
    output$value <- renderText({''})
    # clear link box
    output$link1 <- renderUI({''})

  })

  # my ward button
  points2 <- eventReactive(input$my_ward, {
    if (input$postcode == ""){
      a2 <- google_geocode(as.character(lst[sample(c(1,2,3), size=1),]), key = key1)
    } else
      a2 <- google_geocode(as.character(input$postcode), key = key1)},
    ignoreNULL= TRUE)



  observeEvent(input$my_ward, {

    if (!is.null(points2)) {

      points_a2 <- cbind(lon = points2()$results$geometry$location$lng, lat = points2()$results$geometry$location$lat)

      points_sp2 <- SpatialPoints(points_a2)

      points_df2 <- data.frame(apply(gDistance(points_sp2, shape_leeds, byid = TRUE),1,min))

      # create home.ward variable with distances column
      home.ward <- cbind(shape_leeds,points_df2)
      # set the column name of distances to Distance.from.points
      names(home.ward)[length(names(home.ward))] <- c("Distance.from.points")
      # set home.ward variable to the item where Distance is 0
      home.ward <- home.ward[home.ward@data$Distance.from.points == 0,]
      # generate labels for map
      labels1 <- generate_ward_labels(home.ward)
    }

    output$mymap <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = home.ward,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(home.ward$Description_2018),
                    fillOpacity=0.7,
                    weight = 2,
                    label = labels1) %>%
        addMarkers(data = points2()$results$geometry$location)
    })

    output$value <- renderText({
      HTML(paste0("<div class='result-top-box'>",
                  "Your local ward is ",
                  as.character(home.ward$WARD_NAME[1]),'</div>'))
    })


    if (is.na(home.ward$Email[1])){
      output$link1 <- renderUI({return_results_box(paste0(
        return_injectedButton(return_eventlink_html(home.ward)),
        return_injectedButton(return_dialoguelink_html(home.ward))
      )
      })
      
    } else {
      output$link1 <- renderUI({
        return_results_box(paste0(
          return_injectedButton(return_eventlink_html(home.ward)),
          return_injectedButton(return_email_html(home.ward)),
          return_injectedButton(return_dialoguelink_html(home.ward))
        )
        )
      })
    }
  })
}
