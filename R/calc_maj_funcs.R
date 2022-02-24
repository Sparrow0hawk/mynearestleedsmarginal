# functions for calculating majorities

library(stringr)
library(here)
library(dplyr)

data_tidy <- function(dataframe) {

    stopifnot(c("Ward","Description") %in% colnames(dataframe))
    # remove trailing whitespace
    dataframe$Ward <- trimws(dataframe$Ward)

    str_remove <- c(" Candidate","and Co-operative ")

    for(item in str_remove){
        dataframe$Description <- str_remove(dataframe$Description,
                                         item)
    }

    dataframe$Ward <- str_replace(dataframe$Ward,'&','and')

    return(dataframe)
}

calc_majority <- function(dataframe,position_to_start=1, position_to_compare) {
  #' Calculating majority function
  #' This function takes a dataframe with expecting votes, wards and candidates
  #' it will the calculating the majority of the candidate in 1st place
  #' against a position defined on input
  #' Requires dplyr
  
  # make sure position to compare is an integer
  position_to_compare <- as.integer(position_to_compare)
  
  position_to_start <- as.integer(position_to_start)
  
  # add a rank column by votes and ward
  by_votes <- dataframe %>% arrange(Ward, Votes) %>%
    group_by(Ward) %>% 
    # rank by negative votes column
    # rank orders ascending
    mutate(rank = rank(-Votes, ties.method = "first"))
  
  # create a sliced dataframe taking 
  comparison_frame <- by_votes[by_votes$rank == position_to_start | 
                                 by_votes$rank == position_to_compare,]
  
  # create a new column which has majority of votes calculated
  majority_by_votes <- comparison_frame %>% group_by(Ward) %>%
    mutate(majority = (Votes - lag(Votes, default = first(Votes))))
  
  return(majority_by_votes)
}


join_ward_link <- function(dataframe) {
    ward_const_link <- read.csv(here("assets","data","ward_const_link.csv"), row.names="X")

    joined.data <- dataframe %>%
        left_join(ward_const_link, by = c('Ward' = 'Ward'))

    return(joined.data)
}
