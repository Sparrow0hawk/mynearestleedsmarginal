#!/usr/bin/env bash

DATA_PATH="assets/data"

# download data file
R -e "download.file('https://datamillnorth.org/download/election-results-local/1c4031c8-baa6-41f7-b46c-b7c368c0678f/Results_05May2022.CSV',destfile='assets/data/data2022.csv')"

# rename columns

Rscript scrapbook/rename_cols.R $DATA_PATH/data2022.csv $DATA_PATH/data-new2022.csv CandidateDescription AreaName

# calculate majorities
Rscript scrapbook/calculating_majorities.R $DATA_PATH/data-new2022.csv $DATA_PATH/maj2023.csv

# create geojson file
Rscript scrapbook/singleDF.R $DATA_PATH/maj2023.csv main_file FALSE

# tidy up temporary files
rm $DATA_PATH/data2022.csv $DATA_PATH/data-new2022.csv $DATA_PATH/maj2023.csv
