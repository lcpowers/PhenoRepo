#' Function to predict GCC using parameters fit to warm model
#' 
#' @param params
#' @param test_GDD
#' @param test_targs
#' @param spring_date
#' 
#' 
#' 
#' 
#' 

WarmModelForecast <- function(params,test_GDD,test_targs,spring_date){
  
  gdd = test_GDD$GDDdaily
  total_days = test_GDD$GDDdays
  date = test_GDD$date
  days_passed <- test_GDD$day - test_GDD$day[1] + 1
  gdd_days_passed <- test_GDD$GDDdays - min(test_GDD$GDDdays) + 1
  days_inverse <- 1/days_passed
  n <- length(gdd)
  
  # Parameters
  beta <- params$a * days_passed^2 * (total_days > params$t1 & total_days <= params$t2)    # Green up
  
  delta <- params$b * days_inverse * (total_days > params$t2)           # Leaf Maturation
  
  # Create Data Frame
  output_df <- data.frame(date = test_GDD$date,
                          pred_gcc_90 = rep(NA,n),
                          N = rep(NA,n))
  
  # Model sim
  for ( i in 1:n ) {
    
    # Reset to initial conditions on 2/14 every year
    ifelse (str_detect(test_GDD$date[i],spring_date),
            # Initial conditions
            {
              output_df$pred_gcc_90[i] = params$G_init
              output_df$N[i] = 1 - params$G_init
            },
            # Otherwise, calculate following day from equations
            {
              output_df$pred_gcc_90[i] = (1 - delta[i]) * output_df$pred_gcc_90[i-1] + beta[i] * output_df$N[i-1]
              output_df$N[i] = (1 - beta[i]) * output_df$N[i-1] + delta[i] * output_df$pred_gcc_90[i-1]
            })
  }
  
  forecast_df <- merge(test_targs,output_df,by.x = 'time',by.y='date') %>% 
    select(time,year,siteID,obs_gcc_90=gcc_90,pred_gcc_90) %>% 
    mutate(error=obs_gcc_90-pred_gcc_90)
  
  return(forecast_df)
  
}


