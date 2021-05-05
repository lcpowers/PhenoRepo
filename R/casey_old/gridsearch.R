#----gridsearch()
# Grid search function. This is a companion to optim() in the sense that the 
# setup, arguments, and values returned are similar, and the function to be
# optimized is set up in the same way. It first makes a matrix of the parameter
# combinations and then applies func to the rows.
#
# Arguments
# pvecs:    A list. Each element is a vector of values to be tried for one
#           parameter. Parameters should be listed in the order in which they
#           are taken by func.
# func:     Function to optimize (e.g. ssq, nll), with first argument the vector
#           of parameters over which minimization is to take place. It should
#           return a scalar result.
# mon:      How often to report progress. 10 = every 10%. 100 = off.
# ...:      Further arguments to pass to func.
#
# Returns
# par:      The best set of parameters found.
# value:    The value of func corresponding to par.
# profile:  A matrix of the parameter combinations tried with corresponding
#           values of func.
#
# Brett Melbourne
# 18 Nov 15
#
gridsearch <- function( pvecs, func, mon=10, ... ) {

    if ( class(pvecs) != "list" ) {
        stop("pvecs must be a list")
    }
    
    pgrid <- as.matrix(expand.grid(pvecs))
    n <- nrow(pgrid)
    m <- round( n * mon / 100 ) #We'll report progress every m iterations
    funcvals <- rep(NA,n)
    
    for ( i in 1:n ) {
        funcvals[i] <- func(pgrid[i,],...)
        #Monitor progress
        if ( i %% m == 0 ) {
            print( paste(round(100*i/n),"%",sep=""), quote=FALSE )        
        }
    }

    #Compile results
    best_row <- which.min(funcvals) #Find the minimum
    par <- pgrid[best_row,]
    value <- funcvals[best_row]
    profile <- cbind( pgrid, funcvals )    
    
    return( list(par=par,value=value,profile=profile) )
    
}
