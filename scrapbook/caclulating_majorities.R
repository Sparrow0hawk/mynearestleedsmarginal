# scrapbook file for data manipulation
library(dplyr)

data_2019 <- read.csv("assets/data/Leeds_LE2019_results.csv")

data_2018 <- read.csv("assets/data/2018_results_share1.csv")

by_votes <- data_2018 %>% arrange(Ward, Votes) %>%
  group_by(Ward) %>% 
  # rank by negative votes column
  # rank orders ascending
  mutate(rank = rank(-Votes, ties.method = "first"))

hr.frame <- by_votes[by_votes$Ward == 'Hunslet and Riverside',]

top_2 <- by_votes[by_votes$rank == 2 | by_votes$rank == 3,]

majority_by_votes <- top_2 %>% group_by(Ward) %>%
  mutate(majority = (Votes - lag(Votes, default = first(Votes))))


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

test <- calc_majority(data_2019,1, 2)
