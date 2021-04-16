# Phenology Mechanistic Model Script

library(odin)
library(devtools)
path_pheno_model <- "R/PhenoModel.R"

path_sir_model <- system.file("examples/discrete_deterministic_sir.R", package = "odin")
#######    Compile Model using odin    -------------------------------------

model_generator <- odin::odin(path_pheno_model)
model_generator