# Plotting data trends to see relationships

library(here) #for easy management of file paths within the repository
library(tidyverse)
library(lubridate)

rm(list=ls())

# Read in data
dayOne = as.Date("01-01-18","%m-%d-%y")  # First day with both data sets

# Read and format target data  -------------------------------------------------
targets <- read.csv(file = 'data/pheno/GRSM/GRSM_gccTargets.csv') %>% 
  select(1,3) %>%  # Only keep GCC and date
  filter(!is.na(gcc_90))  # Remove NA's
targets$time <- as.Date(targets$time)  # Convert to date format

#targets <- targets %>% filter(time >= dayOne)  # Remove prior dates
targets$day <- yday(targets$time)  # Day of the year


# Read in weather data ---------------------------------------------------------
weather <- read.csv(file = 'data/drivers/neon/temps_allsites.csv') %>%
  filter(siteID == 'GRSM')

# Read in GDD data  ------------------------------------------------------------
GDD <- read.csv(file = 'data/drivers/neon/GDDandtemp_allsites.csv') %>%
  filter(siteID == 'GRSM') %>%  # Only consider GRSM site
  filter(date >= dayOne)
GDD$day <- yday(GDD$date)




# Plot trends to see relationships

ggplot() +
  geom_point(data = targets, aes(x = as.Date(time), y = gcc_90*50), color = "springgreen4") +
  #geom_point(data = weather, aes(x = as.Date(date), y = daily_min, color = "red")) +
  geom_point(data = GDD, aes(x = as.Date(date), y = GDDdaily), color = "red") +
  labs(x="Day of year",y="GCC 90") +
  theme_classic(base_size = 15)
