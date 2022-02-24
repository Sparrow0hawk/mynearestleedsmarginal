#!/usr/bin/env bash

DATA_PATH="assets/data"

# download data file
R -e "download.file('https://datamillnorth.org/download/election-results-local/773088bc-22fd-496b-9362-82235b230ced/Results_06May2021.CSV',destfile='assets/data/data2021.csv')"

# rename columns

Rscript scrapbook/rename_cols.R $DATA_PATH/data2021.csv $DATA_PATH/data-new2021.csv CandidateDescription AreaName

# calculate majorities
Rscript scrapbook/calculating_majorities.R $DATA_PATH/data-new2021.csv $DATA_PATH/maj2022.csv

# create geojson file
Rscript scrapbook/singleDF.R $DATA_PATH/maj2022.csv main_file FALSE

# tidy up temporary files
rm $DATA_PATH/data2021.csv $DATA_PATH/data-new2021.csv $DATA_PATH/maj2022.csv
