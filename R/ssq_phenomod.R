#' Used to find best fit parameters for WarmModel
#' 
#' @param p A set of input parameters for model being fit
#' @param y Data that model is being fit to
#' @param GDD Temperature data with GDD columns
#' @param spring_date Date to restart model each year. Should be in "-MM-DD" format, with dashes included
#' 

# Sum of Squares Function - used to measure error
ssq_phenmod <- function(p,y,GDD,spring_date) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- WarmModel(GDD,G_init=p[1],a=p[2],b=p[3],green_up=p[4],G_max=p[5],spring_date) #predicted y
  e <- y - y_pred$G #observed minus predicted y
  ssq <- sum(e^2)
  return(ssq)
}
