# Get pheno data

library(tidyverse)
library(corrplot)
library(RColorBrewer)
rm(list=ls())

source("downloadPhenoCam.R")
source("calculatePhenoCamUncertainty.R")

##Selected Sites for Challenge
siteIDs <- c("NEON.D01.HARV.DP1.00033","NEON.D01.BART.DP1.00033","NEON.D02.SCBI.DP1.00033",
             "NEON.D05.STEI.DP1.00033","NEON.D06.UKFS.DP1.00033","NEON.D07.GRSM.DP1.00033",
             "NEON.D08.DELA.DP1.00033","NEON.D11.CLBJ.DP1.00033")


site_names <- c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")

allData <- data.frame(matrix(nrow = 0, ncol = 5))

siteName <- siteIDs[1]
message(siteName)
if(siteName != "NEON.D11.CLBJ.DP1.00033"){
  URL_gcc90 <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_1000_1day.csv",sep="") ##URL for daily summary statistics
  URL_individual <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_1000_roistats.csv",sep="") ##URL for individual image metrics
}else{
  URL_gcc90 <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_2000_1day.csv",sep="") ##URL for daily summary statistics
  URL_individual <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_2000_roistats.csv",sep="") ##URL for individual image metrics
}


phenoData <- download.phenocam(URL = URL_gcc90)


dates <- unique(phenoData$date)
phenoData_individual <- download.phenocam(URL=URL_individual,skipNum = 17)
gcc_sd <- calculate.phenocam.uncertainty(dat=phenoData_individual,dates=dates) ##Calculates standard deviations on daily gcc90 values

subPhenoData <- phenoData %>% 
  mutate(siteID = stringr::str_sub(siteName, 10, 13), 
         time = date) %>% 
  select(time, siteID, gcc_90)
subPhenoData <- cbind(subPhenoData,gcc_sd)

allData <- rbind(allData,subPhenoData)

ggplot(allData,aes(x=time,y=gcc_90))+
  # geom_ribbon(aes(ymin=gcc_90-gcc_sd,ymax=gcc_90+gcc_sd))+
  geom_line(aes(color=gcc_90))+
  scale_color_gradient(low="white",high="darkgreen")+
  theme_classic()
