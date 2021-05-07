

nll_phenmod <- function(p,y,GDD,targets) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- WarmModel(GDD,G_init=p[1],a=p[2],b=p[3],t1=p[4],t2=p[5]) #predicted gcc
  nll <- -sum(dnorm(targets$gcc_90,mean=y_pred$G,sd=as.numeric(p[6]),log=TRUE))
  return(nll)
}
