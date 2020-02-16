# server.R for mynearestleedsmarginal.com

library(shiny)
library(here)
library(leaflet)
library(googleway)
library(sp)
# not needed loading data
library(dplyr)
library(rgeos)

options(shiny.sanitize.errors = TRUE)

# load all preparaed data
load(here("assets","data","testdata1.RData"), envir=.GlobalEnv)

# load 2020 main data
incumbents_df1 <- read.csv(here('assets','data','mainfile_2020.csv'), row.names = 'X')

# load key seats list
keyseats <- as.character(read.csv(here("assets","data","keyseatlist.csv"), header=FALSE)$V1)

# load emails list
emailstbl <- data.frame(read.csv(here("assets","data","emails2019.csv"), encoding = "latin", header=FALSE))

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
                     levels(incumbents_df1$Description))
  
  labels <- sprintf(
    "<strong>%s</strong><br/>%g majority<br/>%s",
    incumbents_df1$Ward, incumbents_df1$majority_2018, incumbents_df1$Description
  ) %>% lapply(htmltools::HTML)
  
  # pressing button on empty postcode input now creates map for centred leeds address
  # additional functionality would be to wildcard several leeds addresses aimed at under populated
  # key seats
  points <- eventReactive(input$go, {
    if (input$postcode == ""){
      a <- lst[sample(c(1,3,5))]
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
                  fillColor = ~pal(incumbents_df1$Description), 
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
      
      names(incumbents_df1) <- c("Party",   #1
                             "Ward",  #2
                             "Majority", #3
                             "Fullname", #4
                             "Majority_2019", #5
                             "Constituency", #6
                             "Link",  #7
                             "Email", #8
                             "Distance from points")  #9
      
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
      
      
      labels1 <- sprintf(
        "<strong>%s</strong><br/>%g majority<br/>%s",
        flt_df_2016majclose$Ward[1], flt_df_2016majclose$Majority[1], as.character(flt_df_2016majclose$Party[1])
      ) %>% lapply(htmltools::HTML)
    }
    
    output$mymap <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = df_2016majmap,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(df_2016majclose$Party[df_2016majclose$Ward %in% df_2016majmap$WARD_NAME]), 
                    fillOpacity=0.7,
                    weight = 2,
                    label = labels1) %>%
        addMarkers(data = points()$results$geometry$location)
    })
    
    
    output$value <- renderText({
      HTML(paste0("<div style='border-color: rgb(230, 0, 71);
                  border-top-style: solid;
                  border-left-style: solid;
                  border-right-style: solid;
                  font-size: 20px;
                  text-align: center;
                  '>",
      "Your nearest marginal is ",as.character(flt_df_2016majclose$Ward[1]),'</div>'))
      })
    
    if (is.na(flt_df_2016majclose$Email[1])){
      output$link1 <- renderUI({
        lnk <- HTML(paste0("<div style='border-color: rgb(230, 0, 71);
                           border-bottom-style: solid;
                           border-left-style: solid;
                           border-right-style: solid;
                           font-size: 20px;
                           text-align: center;
                           '>",
                           "<a href=",as.character(flt_df_2016majclose$Link[1])," class='Linkbutton' target='_blank'",
                           "onclick=ga('send','event','click','near_link','",strsplit(flt_df_2016majclose$Ward[1],' ')[[1]][1],"',1)>See events in this ward</a>"))
        HTML(paste(lnk))})
    } else {
      output$link1 <- renderUI({
        mailto <- HTML(paste0("<div style='border-color: rgb(230, 0, 71);
                           border-bottom-style: solid;
                           border-left-style: solid;
                           border-right-style: solid;
                           font-size: 20px;
                           text-align: center;
                           '>",
                            "<a href='",as.character(flt_df_2016majclose$Email[1]),"?subject=I want to help Labour win!&Body=Hi,%0dI want to volunteer to help Labour win in your seat this year.%0dPlease let me know how I can get involved.%0dThanks!%0d %0d %0d This email was automatically generated because the sender used www.mynearestleedsmarginal.com' class='Linkbutton' target='_blank'",
                            "onclick=ga('send','event','click','near_mailto','",strsplit(flt_df_2016majclose$Ward[1],' ')[[1]][1],"',1)>Email an organiser to volunteer</a>"))
        HTML(paste(mailto))})
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
                    fillColor = ~pal(incumbents_df1$Description), 
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
      a2 <- lst[sample(c(1,3,5))]
    } else
      a2 <- google_geocode(as.character(input$postcode), key = key1)},
    ignoreNULL= TRUE)
  
  observeEvent(input$my_ward, {
    
    if (!is.null(points2)) {
      
      points_a2 <- cbind(lon = points2()$results$geometry$location$lng, lat = points2()$results$geometry$location$lat)
      
      points_sp2 <- SpatialPoints(points_a2)
      
      points_df2 <- data.frame(apply(gDistance(points_sp2, shape_leeds, byid = TRUE),1,min))
      
      incumbents_df1 <- cbind(incumbents_df1,points_df2)
      
      names(incumbents_df1) <- c("Party",   #1
                                 "Ward",  #2
                                 "Majority", #3
                                 "Fullname", #4
                                 "Majority_2019", #5
                                 "Constituency", #6
                                 "Link",  #7
                                 "Email", #8
                                 "Distance from points")  #9
      
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
      
      
      labels1 <- sprintf(
        "<strong>%s</strong><br/>%g majority<br/>%s",
        flt_df_2016majclose$Ward[1], flt_df_2016majclose$Majority[1], as.character(flt_df_2016majclose$Party[1])
      ) %>% lapply(htmltools::HTML)
    }
    
    output$mymap <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addPolygons(data = df_2016majmap,
                    stroke = TRUE,
                    color = "black",
                    fillColor = ~pal(df_2016majclose$Party[df_2016majclose$Ward %in% df_2016majmap$WARD_NAME]), 
                    fillOpacity=0.7,
                    weight = 2,
                    label = labels1) %>%
        addMarkers(data = points()$results$geometry$location)
    })
    
    output$value <- renderText({
      HTML(paste0("<div style='border-color: rgb(230, 0, 71);
                  border-top-style: solid;
                  border-left-style: solid;
                  border-right-style: solid;
                  font-size: 20px;
                  text-align: center;
                  '>",
                  "Your local ward is ",as.character(flt_df_2016majclose$Ward[1]),'</div>'))
    })
    
    
    if (is.na(flt_df_2016majclose$Email[1])){
      output$link1 <- renderUI({
        lnk <- HTML(paste0("<div style='border-color: rgb(230, 0, 71);
                           border-bottom-style: solid;
                           border-left-style: solid;
                           border-right-style: solid;
                           font-size: 20px;
                           text-align: center;
                           '>",
                           "<a href=",as.character(flt_df_2016majclose$Link[1])," class='Linkbutton' target='_blank'",
                           "onclick=ga('send','event','click','mylink','",strsplit(flt_df_2016majclose$Ward[1],' ')[[1]][1],"',1)>See events in this ward</a>"))
        HTML(paste(lnk))})
    } else {
      output$link1 <- renderUI({
        mailto <- HTML(paste0("<div style='border-color: rgb(230, 0, 71);
                              border-bottom-style: solid;
                              border-left-style: solid;
                              border-right-style: solid;
                              font-size: 20px;
                              text-align: center;
                              '>",
                              "<a href='",as.character(flt_df_2016majclose$Email[1]),"?subject=I want to help Labour win!&Body=Hi,%0dI want to volunteer to help Labour win in your seat this year.%0dPlease let me know how I can get involved.%0dThanks!%0d %0d %0d This email was automatically generated because the sender used www.mynearestleedsmarginal.com' class='Linkbutton' target='_blank'",
                              "onclick=ga('send','event','click','mymailto','",strsplit(flt_df_2016majclose$Ward[1],' ')[[1]][1],"',1)>Email an organiser to volunteer</a>"))
        HTML(paste(mailto))})
    }
  })
}

