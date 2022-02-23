#!/usr/bin/env Rscript

# scrapbook file for renaming columns
library(dplyr)
library(here)


source(here("R","calc_maj_funcs.R"))

main <- function(datafile, output_path, des_old, ward_old) {

  data <- read.csv(datafile,
                      stringsAsFactors = TRUE)

  data <- rename(data, Description = des_old, Ward = ward_old)

  write.csv(data, output_path)
}

args <- commandArgs(trailingOnly = TRUE)

if(length(args) < 4){
  stop("Must provide arguments for path to previous election data, output path, old description, old ward")
} else {
  main(args[1], args[2], args[3], args[4])
}
