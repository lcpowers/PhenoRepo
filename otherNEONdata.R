library(neonstore)
library(tidyverse)
library(neonUtilities)
start_date <- "2016-12-13"

RH <- loadByProduct(dpID="DP1.00098.001", 
                    site=c("GRSM"), 
                    startdate=start_date,
                    package="basic",
                    check.size=T)

