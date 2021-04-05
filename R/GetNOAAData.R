
# This function was pulled from the NEON code file
download_noaa_files_s3 <- function(siteID, date, cycle, local_directory){
  
  Sys.setenv("AWS_DEFAULT_REGION" = "data",
             "AWS_S3_ENDPOINT" = "ecoforecast.org")
  
  object <- aws.s3::get_bucket("drivers", prefix=paste0("noaa/NOAAGEFS_1hr/",siteID,"/",date,"/",cycle))
  
  for(i in 1:length(object)){
    aws.s3::save_object(object[[i]], bucket = "drivers", file = file.path(local_directory, object[[i]]$Key))
  }
}

download_noaa_files_s3(siteID = "GRSM", date = "2021-03-10", cycle = "00", local_directory <- "data/drivers/")
library(tidyverse)
library(ncdf4)

a <- nc_open("data/drivers/noaa/NOAAGEFS_1hr/GRSM/2021-03-10/00/NOAAGEFS_1hr_GRSM_2021-03-10T00_2021-03-26T00_ens00.nc")
b <- ncdf4::ncvar_get(nc = a,varid = "air_temperature")

