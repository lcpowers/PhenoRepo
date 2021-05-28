# PhenoRepo
Repository for Team Rotation Project: NEON Ecological Forecasting Phenoloy Challenge

# Project Overview
This repository hosts all project files for team CUPheno's participation in the NEON phenology forecasting challenge. The challenge is hosted by the National Ecological Observatory Network, which provides color channel data and raw images for eight decidious forest observation sites in the eastern United States. The challenge requires participants to forecast the daily green-chromatic coordinate (GCC) of each site at noon for 35 days into the future. The spring 2021 challenge focused specifically on spring green-up across sites. 

# Model Description
We have developed a deterministic, discrete time compartment model to simulate the transition of pixels between green (G) and non-green (N) color channels as the forest moves through yearly transitions. The model is initiated at some greenness value, \TeX("$G_init$"), based on the previous 3 days of data at any point in time. 

# Team Members
This project was driven by IQ Biology PhD students Casey Middleton, Claire Powers, and Josh Huffine for an 8-week team rotation. We were advised by Brett Melbourne (EBIO) and Eric Vance (STATS). 
