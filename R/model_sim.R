# Phenology Mechanistic Model Script

library(odin)
library(devtools)
library(dde)
path_pheno_model <- "R/PhenoModel.R"

#######    Compile Model using odin    -------------------------------------

model_generator <- odin::odin(path_pheno_model)
model <-model_generator() # generate an instance of model

#######   Run Model   -------------------------------------------------------

phen_col = c("#036722","#350c5e")
runs = 10

sims <- model$run(1:runs)

matplot(sims[,1], sims[,-1], xlab = "Time", ylab = "Proportion of pixels",
        type = "l", col = phen_col, lty = 1)
legend("topright", lwd = 1, col = phen_col, legend = c("Green", "Non-Green"), bty = "n")



