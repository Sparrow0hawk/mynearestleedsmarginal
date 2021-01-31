# testing script

library(testthat)
library(here)
library(sp)
library(rgeos)

# load testing dataframe
load(here("app","assets","data","testdata1.RData"), envir=.GlobalEnv)

test_that('testing geocode returns expected lng', {
  library(googleway)
  
  expect_equal(
    round(google_geocode(as.character("LS1 4JL"), key = key1)$results$geometry$location$lng, digits = 3), -1.553 
  )
})

test_that('testing geocode returns expected lat', {
  library(googleway)
  
  expect_equal(
    round(google_geocode(as.character("LS1 4JL"), key = key1)$results$geometry$location$lat, digits=3), 53.796
  )
  
})

test_that(' test the spatial narrowing of ward dataframe HR', {
  points_a <- cbind(lon = -1.553, lat = 53.796)
  
  points_sp <- SpatialPoints(points_a)
  
  points_df <- data.frame(apply(gDistance(points_sp, shape_leeds, byid = TRUE),1,min))
  
  incumbents_df1 <- cbind(incumbents_df1,points_df)
  
  names(incumbents_df1) <- c("Party",   #1
                             "Ward",  #2
                             "Majority", #3
                             "Constituency", #4
                             "Link",  #5
                             #"Email", removed for test
                             "Distance from points")  #7
  
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
  
  wardname <- flt_df_2016majclose$Ward[1]
  
  expect_equal(wardname, 'Hunslet and Riverside')
})


test_that(' test the spatial narrowing of ward dataframe FW', {
  points_a <- cbind(lon = -1.623, lat = 53.814)
  
  points_sp <- SpatialPoints(points_a)
  
  points_df <- data.frame(apply(gDistance(points_sp, shape_leeds, byid = TRUE),1,min))
  
  incumbents_df1 <- cbind(incumbents_df1,points_df)
  
  names(incumbents_df1) <- c("Party",   #1
                             "Ward",  #2
                             "Majority", #3
                             "Constituency", #4
                             "Link",  #5
                             #"Email", removed for test
                             "Distance from points")  #7
  
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
  
  wardname <- flt_df_2016majclose$Ward[1]
  
  expect_equal(wardname, 'Farnley and Wortley')
})

test_that(' test the spatial narrowing of ward dataframe WW', {
  points_a <- cbind(lon = -1.568, lat = 53.834)
  
  points_sp <- SpatialPoints(points_a)
  
  points_df <- data.frame(apply(gDistance(points_sp, shape_leeds, byid = TRUE),1,min))
  
  incumbents_df1 <- cbind(incumbents_df1,points_df)
  
  names(incumbents_df1) <- c("Party",   #1
                             "Ward",  #2
                             "Majority", #3
                             "Constituency", #4
                             "Link",  #5
                             #"Email", removed for test
                             "Distance from points")  #7
  
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
  
  wardname <- flt_df_2016majclose$Ward[1]
  
  expect_equal(wardname, 'Weetwood')
})

