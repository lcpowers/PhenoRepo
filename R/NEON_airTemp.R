library(neonUtilities)
library(tidyverse)
library(neon4cast)

setwd("../data/drivers/neon/")

saat <- loadByProduct(dpID = "DP1.00002.001",
                      site = 'GRSM',
                      startdate = "2017-01",
                      package='basic')
