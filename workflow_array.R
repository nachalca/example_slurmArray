library(dplyr)
library(remakeGenerator)

# Create folders: 
ff <- c('datasets', 'analyses', 'summaries', 'msg', 'output')
sapply(ff, dir.create, showWarnings=FALSE)

# Instructions for dataset simulation
datasets = commands(
  normal16 = normal_dataset(n = 16),
  poisson32 = poisson_dataset(n = 32),
  poisson64 = poisson_dataset(n = 64)) %>%
  expand(values = c("rep1", "rep2"))

# Instructions for run analysis
analyses = analyses(
  commands = commands(
    linear = linear_analysis(..dataset..),
    quadratic = quadratic_analysis(..dataset..)), 
  datasets = datasets)

# Instructions for obtain summaries
summaries = summaries(
  commands = commands(
    mse = mse_summary(..dataset.., ..analysis..),
    coef = coefficients_summary(..analysis..)), 
  analyses = analyses, datasets = datasets, gather = NULL)

# save all instructions
save(datasets, analyses, summaries, file='targets.Rdata')
