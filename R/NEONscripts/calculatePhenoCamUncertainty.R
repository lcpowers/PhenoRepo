##' Calculate the uncertainty (standard deviation) on daily PhenoCam gcc_90 by bootstrap
##'
##' @param dat PhenoCam data dataframe from roistats file
##' @param dates Vector of desired dates to calculate standard deviation for
##' @export
calculate.phenocam.uncertainty <- function(dat,dates) {
  sds <- rep(NA,length(dates))
  nboot <- 50
  for(d in 1:length(dates)){
    # filter for particular date
    dailyDat <- dat[dat$date==dates[d],]
    
    # If data for date d exists
    if(nrow(dailyDat)>0){
      
      # Remove NAs
      dailyDat <- dailyDat[!is.na(dailyDat$gcc),]
      
      # Count number of rows for that date
      nrows <- nrow(dailyDat)
      
      # Create empty vector to store gcc_90 values
      gcc_90s <- rep(NA,nboot)
      
      # Bootstrap gcc_90 values with replacement
      for(j in 1:nboot){
        gcc_90s[j] <- quantile(dailyDat$gcc[sample(x = 1:nrows,size = nrows,replace = T)],0.90)
      }
      
      # Calculate sd for bootstrapped values
      sds[d] <- sd(gcc_90s)
    }else{
      sds[d] <- NA
    }
  }
  return(sds)
}