source("common.R")
load(snakemake@input[['rdata']])
library(DMRcaller)

### create files vector
files = c(snakemake@input[['reports']])


### join biological replicates
treatment = lapply(files,aggregate,treatment)

save.image(snakemake@output[['rdata']])
