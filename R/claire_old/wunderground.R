rm(list=ls())
install.packages("rnoaa")
library(tidyverse)
library(here)
library(rnoaa)

sites <- read_csv(here("sitepoints.csv"))  

grsm <- isd_stations_search(lat = sites$lat[sites$siteID=="GRSM"],lon=sites$long[sites$siteID=="GRSM"])
