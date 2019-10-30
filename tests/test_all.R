# testing script
library(testthat)
library(here)
source(here('marginal-mapper','marginal-mapper-functions.R'))


test_that('test get_geojson', {
  
  sco_wpc <- get_geojson()
  
  expect_equal(as.character(sco_wpc$PCON13NM[1]), 'Aberdeen North')
})

