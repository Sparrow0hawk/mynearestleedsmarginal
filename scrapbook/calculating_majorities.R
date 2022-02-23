#!/usr/bin/env Rscript

# scrapbook file for data manipulation
library(dplyr)
library(here)
library(stringr)

source(here("R","calc_maj_funcs.R"))

main <- function(previous_elec, output_path) {

  data <- read.csv(previous_elec, row.names = 'X',
                      stringsAsFactors = TRUE)

  tidy.data <- data_tidy(data)

  maj.data <- calc_majority(tidy.data, 1, 2)

  maj.data <- join_ward_link(maj.data)

  maj.data <- maj.data[maj.data$majority != 0,]

  write.csv(maj.data, output_path)
}

args <- commandArgs(trailingOnly = TRUE)

if(length(args) == 0){
  stop("Must provide arguments for path to previous election data and output path")
} else if (length(args) == 1) {
  stop("Must provide arguments for path to previous election data AND output path") 
} else {
  main(args[1], args[2])
}
