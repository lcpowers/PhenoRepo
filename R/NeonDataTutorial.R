library(neonUtilities)

options(stringsAsFactors=F)

# Download IS (instrumentation) data
zipsByProduct(dpID = 'DP4.00200.001',site = "GRSM",package = 'basic',startdate = '2017-11')
flux <- stackEddy(filepath = "data/drivers/neon/filesToStack00200/",
                  level=0)

