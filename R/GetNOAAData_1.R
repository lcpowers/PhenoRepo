
library(tidyverse)
library(ncdf4)
library(neonstore)

rm(list=ls())

# This function was pulled from the NEON code file
download_noaa_files_s3 <- function(siteID, date, cycle, local_directory){
  
  Sys.setenv("AWS_DEFAULT_REGION" = "data",
             "AWS_S3_ENDPOINT" = "ecoforecast.org")
  
  object <- aws.s3::get_bucket("drivers", prefix=paste0("noaa/NOAAGEFS_1hr/",siteID,"/",date,"/",cycle))
  
  for(i in 1:length(object)){
    aws.s3::save_object(object[[i]], bucket = "drivers", file = file.path(local_directory, object[[i]]$Key))
  }
}

# Create a nested loop out of this with site as one variable to iterate over and date as another
sites <- c("GRSM")

download_noaa_files_s3(siteID = "GRSM", date = "2021-03-10", cycle = "06", local_directory <- "data/drivers/")

