library(neonstore)

# Sys.setenv("NEONSTORE_HOME" = "/efi_neon_challenge/neonstore")
# Sys.setenv("NEONSTORE_DB" = "/efi_neon_challenge/neonstore")

## Terrestrial
# DP4.00200.001  
# DP1.00094.001 = Soil water content and water salinity
sites <- c("GRSM")

print("Downloading: DP4.00200.001")
neonstore::neon_download(product = "DP4.00200.001", site = sites, type = "basic", start_date = NA, .token = Sys.getenv("NEON_TOKEN"),dir="data/drivers/neon/")
print("Downloading: DP1.00094.001")
neonstore::neon_download(product = "DP1.00094.001", site = sites, type = "basic", start_date = NA, .token = Sys.getenv("NEON_TOKEN"))

neon_store(product = "DP4.00200.001") 
neon_store(table = "SWS_30_minute", n = 50) 

neon_download(product = "DP4.00001.001", # Summary weather statistics
              start_date = NA,
              end_date = "2019-12-31",   # end date for training data
              site = target.sites,       # target sites defined from 00_Target_Species_EDA.Rmd
              type = "basic")    
