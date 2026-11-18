# Turns the fake CSV files into the package's example datasets.
# Run once from the package folder; it writes data/*.rda
pk_doses <- read.csv("data-raw/doses.csv")
pk_levels <- read.csv("data-raw/levels.csv")
pk_covariates <- read.csv("data-raw/covariates.csv")
dir.create("data", showWarnings = FALSE)
save(pk_doses, file = "data/pk_doses.rda")
save(pk_levels, file = "data/pk_levels.rda")
save(pk_covariates, file = "data/pk_covariates.rda")
