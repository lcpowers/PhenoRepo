library(tidyverse)

rm(list=ls())
source("R/NEONscripts/noaa_gefs_read.R")
base_dir <- "data/drivers/noaa/NOAAGEFS_1hr"

date <- "2020-11-10"

cycle <- "06"

sites <- c("GRSM")

# DF here is the NOAA forecast data
df <- noaa_gefs_read(base_dir, date, cycle, sites)
