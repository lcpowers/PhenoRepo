# Sum of Squares Function - used to measure error
ssq_phenmod <- function(p,y,GDD) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- WarmModel(GDD,G_init=p[1],a=p[2],b=p[3],t1=p[4],t2=p[5]) #predicted y
  e <- y - y_pred$G #observed minus predicted y
  ssq <- sum(e^2)
  return(ssq)
}