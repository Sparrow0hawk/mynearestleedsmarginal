# server.R for mynearestleedsmarginal.com
source(here('R','utils.R'))
library(shiny)
library(here)
library(leaflet)
library(googleway)
library(sp)
# not needed loading data
library(dplyr)
library(rgeos)
library(rgdal)

options(shiny.sanitize.errors = TRUE)

# load all preparaed data
# gives magic number error
#load(here("assets","data","geodata.Rdata"), envir=.GlobalEnv)

shape_leeds <- readOGR(here("assets","data","leedswards2018.geojson"))

lst <- read.csv(here("assets","data","sampleloc.csv"), row.names = "X")

# load googleways key file
key1 <- read.csv(here("assets","data","googleways_key.txt"),
                 row.names = 'X',
                 stringsAsFactors = FALSE)[[1]]

# load 2020 main data
incumbents_df1 <- read.csv(here('assets','data','mainfile_2020.csv'),
                           row.names = 'X',
                           stringsAsFactors = FALSE)

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
incumbents_df1 <- left_join(incumbents_df1, emailstbl, by = "Ward")

# order main dataframe by maps data
incumbents_df1 <- incumbents_df1[order(match(incumbents_df1$Ward,
                                             shape_leeds$WARD_NAME)),]


server <- function(input, output, session) {

  pal <- colorFactor(palette = polpartycol,
                     levels(as.factor(incumbents_df1$Description_2018)))

  labels <- generate_ward_labels(incumbents_df1)

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
                  fillColor = ~pal(incumbents_df1$Description_2018),
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

      incumbents_df1 <- cbind(incumbents_df1,points_df)

      names(incumbents_df1) <- c("Description_2018",   #1
                                 "Ward",  #2
                                 "majority_2018", #3
                                 "Fullname", #4
                                 "majority_2019", #5
                                 "Description_2019", #6
                                 "Constituency", #7
                                 "Link",  #8
                                 "Email", #9
                                 "Distance from points")  #10

      # NEW SECTION RESOLVING PLOTTING CRASH FOR POSTCODES OUTSIDE OF LEEDS
      # pulls out the constituency of postcode entered
      if (0 %in% incumbents_df1[,"Distance from points"]){
        my_const <- filter(incumbents_df1,incumbents_df1[,"Distance from points"]==0)

        # creates a variable of inputted constituency
        my_const <- my_const$Constituency
      }else
        my_const <- "Other"
      # END OF NEW SECTION

      df_2016majclose <- incumbents_df1

      # filter list for only key seat list
      # REMOVED FOR 2019 pending recommendations
      df_2016majclose <- df_2016majclose %>%
        filter(Ward %in% keyseats)

      # checks whether inputted postcode constituency is present in
      # key seats list, to ensure within constituency filter
      if(my_const %in% df_2016majclose$Constituency){
        df_2016majclose <- df_2016majclose %>%
          filter(Constituency %in% my_const)
      }

      # arranges by distance (nearest first) key seats list
      flt_df_2016majclose <- arrange(df_2016majclose,
                                     df_2016majclose[,"Distance from points"])

      df_2016majmap <- shape_leeds[as.character(shape_leeds$WARD_NAME) %in%
                                    as.character(flt_df_2016majclose$Ward[1]),]


      labels1 <- generate_ward_labels(incumbents_df1)
    }

    output$mymap <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = df_2016majmap,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(df_2016majclose$Description_2018[df_2016majclose$Ward %in% df_2016majmap$WARD_NAME]),
                    fillOpacity=0.7,
                    weight = 2,
                    label = labels1) %>%
        addMarkers(data = points()$results$geometry$location)
    })


    output$value <- renderText({
      HTML(paste0("<div class='result-top-box'>",
      "Your nearest marginal is ",
      as.character(flt_df_2016majclose$Ward[1]),'</div>'))
      })

    if (is.na(flt_df_2016majclose$Email[1])){
      output$link1 <- renderUI({return_eventlink_html(flt_df_2016majclose)})
      
    } else {
      output$link1 <- renderUI({
        return_email_html(flt_df_2016majclose)
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
                    fillColor = ~pal(incumbents_df1$Description_2018),
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

      incumbents_df1 <- cbind(incumbents_df1,points_df2)

      names(incumbents_df1) <- c("Description_2018",   #1
                                 "Ward",  #2
                                 "majority_2018", #3
                                 "Fullname", #4
                                 "majority_2019", #5
                                 "Description_2019", #6
                                 "Constituency", #7
                                 "Link",  #8
                                 "Email", #9
                                 "Distance from points")  #10

      # NEW SECTION RESOLVING PLOTTING CRASH FOR POSTCODES OUTSIDE OF LEEDS
      # pulls out the constituency of postcode entered
      if (0 %in% incumbents_df1[,"Distance from points"]){
        my_const <- filter(incumbents_df1,incumbents_df1[,"Distance from points"]==0)

        # creates a variable of inputted constituency
        my_const <- my_const$Constituency
      }else
        my_const <- "Other"
      # END OF NEW SECTION

      df_2016majclose <- incumbents_df1

      # checks whether inputted postcode constituency is present in
      # key seats list, to ensure within constituency filter
      if(my_const %in% df_2016majclose$Constituency){
        df_2016majclose <- df_2016majclose %>%
          filter(Constituency %in% my_const)
      }

      # arranges by distance (nearest first) key seats list
      flt_df_2016majclose <- arrange(df_2016majclose,
                                     df_2016majclose[,"Distance from points"])

      df_2016majmap <- shape_leeds[as.character(shape_leeds$WARD_NAME) %in%
                                     as.character(flt_df_2016majclose$Ward[1]),]


      labels1 <- generate_ward_labels(incumbents_df1)
    }

    output$mymap <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = df_2016majmap,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(df_2016majclose$Description_2018[df_2016majclose$Ward %in% df_2016majmap$WARD_NAME]),
                    fillOpacity=0.7,
                    weight = 2,
                    label = labels1) %>%
        addMarkers(data = points2()$results$geometry$location)
    })

    output$value <- renderText({
      HTML(paste0("<div class='result-top-box'>",
                  "Your local ward is ",
                  as.character(flt_df_2016majclose$Ward[1]),'</div>'))
    })


    if (is.na(flt_df_2016majclose$Email[1])){
      output$link1 <- renderUI({return_eventlink_html(flt_df_2016majclose)})
      
    } else {
      output$link1 <- renderUI({
       return_email_html(flt_df_2016majclose)
        })
    }
  })
}
