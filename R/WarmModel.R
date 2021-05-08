#' Phenology Model - Spring and Summer Only
#'
#' Input parameters:
#' @param GDD daily growing degree day values
#' @param G_init Initial green value
#' @param a FIT 
#' @param b FIT
#' @param t1 FIT start greenup
#' @param t2 FIT start leaf maturation
#' @param spring_date Date to restart model each year. Should be in "-MM-DD" format, with dashes included
#' 

WarmModel <- function(GDD,G_init,a,b,green_up,G_max,spring_date) {
  
  # GDD Input Data
  gdd = GDD$GDDdaily
  total_days = GDD$GDDdays
  date = GDD$date
  days_passed <- GDD$day
  gdd_days_passed <- GDD$GDDdays
  days_inverse <- 1/gdd_days_passed
  n <- length(gdd)
  
  # Parameters
  beta <- a * (total_days > green_up)                  # Green up
  
  delta <- b * days_inverse * (total_days > green_up)  # Leaf Maturation
  
  # Create Data Frame
  output_df <- data.frame(date = GDD$date,
                          G = rep(NA,n),
                          N = rep(NA,n))

  
  # Model sim
  for ( i in 1:n ) {
    
    # Reset to initial conditions on 2/14 every year
    ifelse (str_detect(GDD$date[i],spring_date),
    # If start of year, initialize values
      {
      # Boolean for second epoch switch
      summer_true = FALSE
      spring_true = TRUE
      
      # Initial conditions
      output_df$G[i] = G_init
      output_df$N[i] = 1 - G_init
      },
    # Otherwise, calculate following day from equations
      {
        
      # Update bool for spring to summer epoch switch
      if (isTRUE(spring_true) & isTRUE(output_df$G[i-1] >= G_max)){
        summer_true = TRUE
        spring_true = FALSE
      }
        
      # Generate time series data
      output_df$G[i] = (1 - (delta[i] * summer_true)) * output_df$G[i-1] + 
        beta[i] * spring_true * output_df$N[i-1]
      
      output_df$N[i] = (1 - (beta[i] * spring_true)) * output_df$N[i-1] + 
          delta[i] * summer_true * output_df$G[i-1]
      
    })
  }
  return(output_df)
  
}

