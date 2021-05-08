#' Function to predict GCC using parameters fit to warm model
#' 
#' @param params
#' @param test_GDD
#' @param test_targs
#' @param spring_date
#' 
#' 


WarmModelForecast <- function(params,test_GDD,test_targs,spring_date) {
  
  # GDD Input Data
  gdd = test_GDD$GDDdaily
  total_days = test_GDD$GDDdays
  date = test_GDD$date
  days_passed <- test_GDD$day
  gdd_days_passed <- test_GDD$GDDdays
  days_inverse <- 1/gdd_days_passed
  n <- length(gdd)
  
  # Parameters
  beta <- params$a * (total_days > params$green_up)                  # Green up
  
  delta <- params$b * days_inverse * (total_days > params$green_up)  # Leaf Maturation
  
  # Create Data Frame
  output_df <- data.frame(date = test_GDD$date,
                          pred_gcc_90 = rep(NA,n),
                          N = rep(NA,n))
  
  
  # Model sim
  for ( i in 1:n ) {
    
    # Reset to initial conditions on 2/14 every year
    ifelse (str_detect(test_GDD$date[i],params$spring_date),
            # If start of year, initialize values
            {
              # Boolean for second epoch switch
              summer_true = FALSE
              spring_true = TRUE
              
              # Initial conditions
              output_df$pred_gcc_90[i] = params$G_init
              output_df$N[i] = 1 - params$G_init
            },
            # Otherwise, calculate following day from equations
            {
              
              # Update bool for spring to summer epoch switch
              if (isTRUE(spring_true) & isTRUE(output_df$pred_gcc_90[i-1] >= params$G_max)){
                summer_true = TRUE
                spring_true = FALSE
              }
              
              # Generate time series data
              output_df$pred_gcc_90[i] = (1 - (delta[i] * summer_true)) * output_df$pred_gcc_90[i-1] + 
                beta[i] * spring_true * output_df$N[i-1]
              
              output_df$N[i] = (1 - (beta[i] * spring_true)) * output_df$N[i-1] + 
                delta[i] * summer_true * output_df$pred_gcc_90[i-1]
              
            })
  }
  
  forecast_df <- merge(test_targs,output_df,by.x = 'time',by.y='date') %>% 
    select(time,year,day,siteID,obs_gcc_90=gcc_90,pred_gcc_90) %>% 
    mutate(error=obs_gcc_90-pred_gcc_90)
  
  return(forecast_df)
  
}


