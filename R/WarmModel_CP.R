#' Phenology Model considering part of winter, spring, and summer only
#'
#' @param temp_df A dataframe with daily mean temperature values 
#' @param temp_var Name of column in temp df to use as beta and delta predictor variable
#' @param G_init Initial gcc 90 value
#' @param a parameter in gcc growth rate during green up period FIT BY MODEL
#' @param b paramter used in gcc decay rate during fall senescence FIT BY MODEL
#' @param t1 start date for green up time period FIT BY MODEL
#' @param t2 start date for summer leaf maturation period FIT BY MODEL
#' @param spring_date earliest date for input model data per yer
#' @param fall_date end data for input model data per year
#' @param K gcc carrying capacity FIT BY MODEL
#' 
#' @return dataframe of dates, predicted GCC values and non-GCC values values
#' 


WarmModel_CP <- function(temp_df,temp_var,G_init,a,b,t1,t2,spring_date,fall_date,K) {
  
  tempcol <- which(colnames(temp_df)==temp_var)
  tempdata <- temp_df[,tempcol]
  date = temp_df$date
  n <- length(date)
  
  beta <- a * tempdata * (tempdata > t1 & tempdata <= t2) # Green up 
  delta <- b * tempdata * (tempdata > t2)  
  
  # Start building output dateframe
  output_df <- data.frame(date = date,
                          G = rep(NA,n),
                          N = rep(NA,n))
  
  for (i in 1:n) {
    
    # Reset to initial conditions on spring_date every year
    ifelse(yday(output_df$date[i]) == yday(as.Date(spring_date,"%m-%d-%y")),
           
           # Initial conditions
           {
             output_df$G[i] = G_init
             output_df$N[i] = 1 - G_init
           },
           
           # Otherwise, calculate following day from equations
           {
             output_df$G[i] = (1 - delta[i]) * output_df$G[i-1] + beta[i] * output_df$N[i-1] * (1 - output_df$N[i-1]/K)
             output_df$N[i] = (1 - beta[i]) * output_df$N[i-1] + delta[i] * output_df$G[i-1]
           })
  }
  return(output_df)
  
}


