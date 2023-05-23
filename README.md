#PhenoRepo
Repository for Team Rotation Project: NEON Ecological Forecasting Phenology Challenge

# Project Overview
This repository hosts all project files for team CUPheno's participation in the NEON phenology forecasting challenge. The challenge is hosted by the National Ecological Observatory Network, which provides color channel data and raw images for eight decidious forest observation sites in the eastern United States. The challenge requires participants to forecast the daily green-chromatic coordinate (GCC) of each site at noon for 35 days into the future. The spring 2021 challenge focused specifically on spring green-up across sites. 

# Model Description
We have developed a deterministic, discrete time compartment model to simulate the transition of pixels between green (G) and non-green (N) color channels as the forest moves through yearly transitions. The model is initiated at some greenness value, G_init, based on the previous 3 days of data at any point in time. Three epochs with distinct growth rates are considered: winter dormancy, which has no significant growth or decay; spring green-up, modeled by steep linear growth; and summer leaf maturation, modeled by inverse exponential decay. The transition from winter to spring green-up is based on the number of growing-degree days (GDD's) accumulated since January 1 of the given year, using NEON's temperature data. The transition from spring green-up to summer leaf maturation occurs when the maximum GCC value is reach, informed by the historically observed data. Five parameters are fit to all existing historical data: initial GCC, spring growth rate, summer decay rate, winter-spring transition (GDD), and spring-summer transition (GCC maximum). The parameter combination that minimizes the sum of the squares when comparing model predictions to historical data for each site was used for forecasting. A scaled k-fold cross validation method was used to predcit the model uncertainty. 

# Team Members
This project was driven by IQ Biology PhD students Casey Middleton, Claire Powers, and Josh Huffine for an 8-week team rotation. We were advised by Brett Melbourne (EBIO) and Eric Vance (APPM). 
