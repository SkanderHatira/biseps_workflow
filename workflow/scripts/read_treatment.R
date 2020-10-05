source("common.R")
load(snakemake@input[['rdata']])
library(DMRcaller)

### create files vector
files = c(snakemake@input[['reports']])
conditions= c("control",snakemake@wildcards[["sample"]])
### join biological replicates
treatment = lapply(files,aggregate)
joinedTreatment = lapply(treatment,joinBio)

save.image(snakemake@output[['rdata']])
