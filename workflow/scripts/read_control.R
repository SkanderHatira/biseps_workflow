source("common.R")
library(DMRcaller)

### create files vector
files = c(snakemake@input[['reports']])

### join biological replicates
control = lapply(files,aggregate)
names(control) = c(snakemake@wildcards[['sample']])
if (length(files) > 1){
	join = control[[1]]
	join = joinBio(control[-1])
}




save.image(snakemake@output[['Rdata']])
