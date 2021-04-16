# Phenology Mechanistic Model Script

library(odin)
path_pheno_model <- system.file("./PhenoModel.R", package = "odin")


#######    Compile Model using odin    -------------------------------------

model_generator <- odin::odin(path_pheno_model)
model_generator