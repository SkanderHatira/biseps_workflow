source("common.R")
load(snakemake@input[['Rdata']])
library(DMRcaller)

### create files vector
files = c(snakemake@input[['reports']])

### create empty vector of length (files) 
control <- vector(mode="list", length=length(files))

### join biological replicates
lapply(files,aggregate,control)

save.image(snakemake@output[['Rdata']])
