
# remotes::install_deps()

library('tidyverse')
rm(list=ls())

# Run nullModel_randomWalk_main.R
# If interested in particular dates, go in a change the filter on the phenoDat date range
source("R/NEONscripts/nullModel_randomWalk_main.R")
write_csv(forecast_saved, paste0("R/score_dfs/nullmodel4cast_",Sys.Date(),".csv"))
