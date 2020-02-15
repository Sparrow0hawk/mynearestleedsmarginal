# scrapbook file for data manipulation
library(dplyr)
library(here)

data_2019 <- read.csv("assets/data/Leeds_LE2019_results.csv", row.names = 'X')

data_2018 <- read.csv("assets/data/2018_results_share1.csv", row.names = 'X')

by_votes <- data_2018 %>% arrange(Ward, Votes) %>%
  group_by(Ward) %>% 
  # rank by negative votes column
  # rank orders ascending
  mutate(rank = rank(-Votes, ties.method = "first"))

top_2 <- by_votes[by_votes$rank == 2 | by_votes$rank == 3,]

majority_by_votes <- top_2 %>% group_by(Ward) %>%
  mutate(majority = (Votes - lag(Votes, default = first(Votes))))

# functionize above
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

##### Wrangling section using function #####
# get 2018 and 2019 data for combining

# get majorities for candidates who came 2nd in 2018 
# and maybe restanding in 2020
result_2018 <- calc_majority(data_2018,2, 4)

# get majorities from 2019 for side by side show
result_2019 <- calc_majority(data_2019, 1, 2)

# get all 2nd place candidates and majorities
secplace_2018 <- result_2018[result_2018$majority != 0,]

secplace_2019 <- result_2019[result_2019$majority != 0,]

# create base frame to work with

base_frame <- secplace_2018[,c('Surname','Forename',
                               'Description','Ward',
                               'majority')]

# create single name variable and drop two other name columns
base_frame <- base_frame %>%
  mutate(fullname = paste0(Forename,' ',Surname)) %>%
  select(-c('Surname','Forename'))

# add 2019 majority onto base frame
base_frame.2019 <- base_frame %>% 
  left_join(secplace_2019[,c('Ward','majority')], 
            by = c('Ward' = 'Ward'),
            suffix = c('_2018','_2019')
            )

