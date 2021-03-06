Tutorial on optimization
================
Brett Melbourne
16 Apr 2021 (updated 24 Apr 2021)

``` r
library(here) #for easy management of file paths within the repository
source(here("R/gridsearch.R")) #for gridsearch() function
```

## Background lecture on optimization algorithms

From week 3 of my data science class:

  - 10 min video lecture:
  - <https://www.dropbox.com/s/uyb8v9s2s5c1k92/wk3_vid1_optim_algos.mp4?dl=0>
  - Class notes:
  - <https://github.com/EBIO5460Fall2020/class-materials/blob/master/03_1_slides_optim_algos.pdf>

## Example: fitting a linear model with SSQ algorithm

In the code below, I give an example that demonstrates using a grid
search followed by the Nelder-Mead descent algorithm to find the minimum
in the case of a simple linear model with sum of squares as the function
to be minimized (in other words, this is simple linear regression done
the hard way).

Model fitting has three components:  
1\) A function for the linear model.  
2\) A function to calculate SSQ.  
3\) A call to `gridsearch()` or `optim()`.

In this particular example, there is no strong advantage to separating
out the model from the SSQ function, or indeed for using a grid search
first, but this approach generalizes better to more complex models
(e.g. nonlinear dynamical models) so I demonstrate it here.

The functions `gridsearch()` and `optim()` are set up in the same way.
Read the help for `optim()`, noting how to pass parameters and data.
Parameters need to be in a vector and data need to be passed through the
“…” part of `optim()`.

``` r
?optim
```

See also the source code for `gridsearch()`. Open the file or you can
use:

``` r
file.show(here("R/gridsearch.R"))
```

### The data

Our goal is to fit a linear model to these data:

``` r
linear_data <- read.csv(here("R/OptimizingTutorial_data.csv"))
plot(linear_data$x,linear_data$y)
```

![](OptimizingTutorial_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

### Function definitions

We need to define functions for the linear model and the SSQ.

``` r
# A function for the linear model. This is the model algorithm.
# Returns a vector of y for the model:
#    y = b_0 + b_1 * x
# b_0: y intercept
# b_1: slope
#
linmod <- function(b_0,b_1,x) {
    y <- b_0 + b_1 * x
    return(y)
}
```

``` r
# Returns the sum of squares for the linear model. This is set
# up for use with gridsearch() and optim().
# p:  vector of parameter values c(b_0, b_1) 
# y:  vector of data for y
# x:  vector of data for x
#
ssq_linmod <- function(p,y,x) {
    #In the next line we refer to the parameters in p by name so that the code
    #is self documenting
    y_pred <- linmod(b_0=p[1],b_1=p[2],x) #predicted y
    e <- y - y_pred #observed minus predicted y
    ssq <- sum(e^2)
    return(ssq)
}
```

### Grid search algorithm

First use a grid search algorithm to characterize the SSQ profile. From
the plotted data, it looks like a reasonable range to try for the
y-intercept is 100 to 300, and for the slope is -2 to -5.

Set up parameters to try (`gridsearch()` requires a list of vectors)

``` r
pvecs <- list(b_0=seq(100,300,length.out=50),
              b_1=seq(-2,-5,length.out=50))
```

Grid search

``` r
fit <- gridsearch(pvecs, ssq_linmod, y=linear_data$y, x=linear_data$x)
```

    ## [1] 10%
    ## [1] 20%
    ## [1] 30%
    ## [1] 40%
    ## [1] 50%
    ## [1] 60%
    ## [1] 70%
    ## [1] 80%
    ## [1] 90%
    ## [1] 100%

The best parameter values found by the grid search are in `fit$par`.
These are not the best possible values that could be found, only the
best found so far from the parameter combinations we tried.

``` r
fit$par
```

    ##        b_0        b_1 
    ## 193.877551  -3.285714

The minimum SSQ found so far is in `fit$value`.

``` r
fit$value
```

    ## [1] 35600.55

Plot SSQ profiles. The parameter combinations we tried and their SSQ
values are in `fit$profile`.

``` r
par(mfrow=c(1,2))
plot(funcvals~b_0,data=fit$profile)
plot(funcvals~b_1,data=fit$profile)
```

![](OptimizingTutorial_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

The plot is too zoomed out so zoom in by adjusting the y-axis limits

``` r
par(mfrow=c(1,2))
ylim <- c(min(fit$value),100000)
plot(funcvals~b_0,data=fit$profile,ylim=ylim)
plot(funcvals~b_1,data=fit$profile,ylim=ylim)
```

![](OptimizingTutorial_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

We see that the basin in the SSQ profile for each parameter is nicely
defined. In other words, the SSQ profile is nicely behaved with one
well-defined optimum. We expect this in the case of a simple linear
model but this can be super important for nonlinear models, where the
surface can be highly irregular and complicated by local minima.

### Nelder-Mead algorithm

Now we’ll use the Nelder-Mead descent algorithm with starting parameters
in the basin we just identified in the grid search.

Put the starting parameters in a vector

``` r
starts <- c(fit$par["b_0"],fit$par["b_1"])
```

Call `optim()` for Nelder-Mead

``` r
fit <- optim( starts, ssq_linmod, y=linear_data$y, x=linear_data$x )
fit
```

    ## $par
    ##        b_0        b_1 
    ## 195.010398  -3.327006 
    ## 
    ## $value
    ## [1] 35560
    ## 
    ## $counts
    ## function gradient 
    ##       67       NA 
    ## 
    ## $convergence
    ## [1] 0
    ## 
    ## $message
    ## NULL

`$par` gives the optimized parameter values.  
`$value` gives the minimum SSQ.  
`$counts` gives the number of times the function was evaluated.  
`$convergence` signals whether the algorithm converged (0 if it did
converge).

### Visualize the fit

Calculate fitted model for best parameter values. The values of `y` for
the best-fit parameters are also called “fitted values” or “predicted
values”.

``` r
y_pred <- linmod( b_0=fit$par[1], b_1=fit$par[2], linear_data$x )
```

Plot the fitted model with the data

``` r
par(mfrow=c(1,1))
plot(linear_data$x,linear_data$y)
points(linear_data$x,y_pred,col="red")
abline(fit$par[1],fit$par[2],col="red")
# Add the deviations if you want to be fancy
segments(linear_data$x,y_pred,linear_data$x,linear_data$y,col="green")
```

![](OptimizingTutorial_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

### How does this relate to the lm() function?

R’s `lm()` function uses a different algorithm (householder algorithm
for QR decomposition to solve the system of linear equations) to find
the minimum SSQ. Here’s `lm()` for comparison.

``` r
lmfit <- lm(y~x,data=linear_data)
```

The estimated coefficients are the same as our `optim()` fit

``` r
lmfit
```

    ## 
    ## Call:
    ## lm(formula = y ~ x, data = linear_data)
    ## 
    ## Coefficients:
    ## (Intercept)            x  
    ##     195.009       -3.327

The minimum SSQ is the same (See Residuals: Sum Sq) as our `optim()` fit

``` r
anova(lmfit)
```

    ## Analysis of Variance Table
    ## 
    ## Response: y
    ##           Df Sum Sq Mean Sq F value    Pr(>F)    
    ## x          1 254514  254514  701.42 < 2.2e-16 ***
    ## Residuals 98  35560     363                      
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

## Maximum likelihood algorithm

The minimizing SSQ algorithm gives a good intuition for the general idea
of fitting a model to data by optimization. The general idea is to
minimize the distance between the model predictions and the data. The
parameter values that minimize the distance are the best fit. We can
improve on this by switching out SSQ in the objective function for
likelihood, which you can think of as a distance that is calibrated in
terms of probability.

### Likelihood for the Normal linear model

The likelihood is the probability of the data given the model,
![P(y|\\theta)](https://latex.codecogs.com/png.latex?P%28y%7C%5Ctheta%29
"P(y|\\theta)"), where
![\\theta](https://latex.codecogs.com/png.latex?%5Ctheta "\\theta")
represents the parameters. In practice, we are also conditioning on any
independent variables. The likelihood function for the Normal linear
model is:

  
![P(y|\\theta) = P(y|\\beta\_0,\\beta\_1,\\sigma,x)
=&#10;\\prod\_i^n\\frac{1}{\\sqrt{2\\pi\\sigma^2}}e^{-\\frac{1}{2}\\frac{(y\_i-\\beta\_0-\\beta\_1&#10;x\_i)}{\\sigma^2}}](https://latex.codecogs.com/png.latex?P%28y%7C%5Ctheta%29%20%3D%20P%28y%7C%5Cbeta_0%2C%5Cbeta_1%2C%5Csigma%2Cx%29%20%3D%0A%5Cprod_i%5En%5Cfrac%7B1%7D%7B%5Csqrt%7B2%5Cpi%5Csigma%5E2%7D%7De%5E%7B-%5Cfrac%7B1%7D%7B2%7D%5Cfrac%7B%28y_i-%5Cbeta_0-%5Cbeta_1%0Ax_i%29%7D%7B%5Csigma%5E2%7D%7D
"P(y|\\theta) = P(y|\\beta_0,\\beta_1,\\sigma,x) =
\\prod_i^n\\frac{1}{\\sqrt{2\\pi\\sigma^2}}e^{-\\frac{1}{2}\\frac{(y_i-\\beta_0-\\beta_1
x_i)}{\\sigma^2}}")  

where the RHS of the equation is the product of the probabilities of
individual data points (assuming that each data point is independent).
The equation inside the product operator is the probability density
function (pdf) of the Normal distribution. To fit the model, we take the
natural logarithm and change sign to get the **negative
log-likelihood**, also known as the support function. This
transformation is not conceptually necessary but it improves the
accuracy and stability of the optimization algorithm: instead of
multiplying tiny probabilities together it is more accurate and
convenient to sum their logs. The optimization algorithm minimizes
functions by default, so we take the negative.

### Function definition for the likelihood objective function

The R code for the negative log-likelihood of the linear model is:

``` r
lm_nll <- function(p,y,x) {
    mu <- linmod(b_0=p[1],b_1=p[2],x) #call the linear model
    nll <- -sum(dnorm(y,mean=mu,sd=p[3],log=TRUE)) #-1 * sum of log-likelihoods 
    return(nll)
}
```

Compared to the SSQ function, we’ve switched out the line of code for
calculating the SSQ with a line that calculates the negative log
likelihood. Also, the vector `p` now includes an additional parameter,
the standard deviation of the Normal distribution. The first line inside
the function calculates
![\\mu\_i](https://latex.codecogs.com/png.latex?%5Cmu_i "\\mu_i"), the
expected value of ![y\_i](https://latex.codecogs.com/png.latex?y_i
"y_i"), by calling the linear model with the first two parameters of the
parameter vector `p`, which are respectively
![\\beta\_0](https://latex.codecogs.com/png.latex?%5Cbeta_0 "\\beta_0")
and ![\\beta\_1](https://latex.codecogs.com/png.latex?%5Cbeta_1
"\\beta_1"). The second line uses the pdf of the Normal distribution to
calculate the log-likelihoods for each datapoint using the R function
`dnorm()`. The log-likelihoods are then summed and made negative. Thus,
this function returns the negative log-likelihood for a given set of
parameters.

For example, let’s try the model
![\\beta\_0=70](https://latex.codecogs.com/png.latex?%5Cbeta_0%3D70
"\\beta_0=70"),
![\\beta\_1=8](https://latex.codecogs.com/png.latex?%5Cbeta_1%3D8
"\\beta_1=8"), and
![\\sigma=30](https://latex.codecogs.com/png.latex?%5Csigma%3D30
"\\sigma=30") and get its negative log-likelihood:

``` r
p <- c(70,8,30)
lm_nll(p,y=linear_data$y, x=linear_data$x)
```

    ## [1] 3391.726

### Optimizing to find the maximum likelihood

As for SSQ, we use grid search and/or Nelder-Mead to find the parameters
that maximize the likelihood. In practice, we achieve this by finding
the parameters that minimize the negative log-likelihood. Compared to
SSQ, we’ve now got a third parameter,
![\\sigma](https://latex.codecogs.com/png.latex?%5Csigma "\\sigma"), to
search over. We need a good place to start for
![\\sigma](https://latex.codecogs.com/png.latex?%5Csigma "\\sigma"),
which is about half the average range of the data in any slice through
![x](https://latex.codecogs.com/png.latex?x "x"), so maybe about 50/2.
Combining with reasonable starting values from before for the other two
parameters:

``` r
starts <- c(194,-3,50/2)
fitlm <- optim(p=starts,lm_nll,y=linear_data$y, x=linear_data$x)
fitlm
```

    ## $par
    ## [1] 195.008258  -3.326902  18.854708
    ## 
    ## $value
    ## [1] 435.5842
    ## 
    ## $counts
    ## function gradient 
    ##      100       NA 
    ## 
    ## $convergence
    ## [1] 0
    ## 
    ## $message
    ## NULL

The maximum likelihood estimates of the parameters are in `$par`:
![\\beta\_0=195](https://latex.codecogs.com/png.latex?%5Cbeta_0%3D195
"\\beta_0=195"),
![\\beta\_1=-3.33](https://latex.codecogs.com/png.latex?%5Cbeta_1%3D-3.33
"\\beta_1=-3.33"), and
![\\sigma=18.9](https://latex.codecogs.com/png.latex?%5Csigma%3D18.9
"\\sigma=18.9"). The negative log-likelihood of this model is in
`$value`: 435.6. We can also see that the function was evaluated 100
times, while the convergence code of 0 tells us that the Nelder-Mead
algorithm converged to an optimum. There is not a guarantee that this is
the global optimum and we would want to inspect a grid search and/or try
a range of starting values to ensure that the likelihood surface is nice
and basin shaped and that there is not a better optimum.
