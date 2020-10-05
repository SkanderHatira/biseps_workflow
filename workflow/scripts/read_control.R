source("common.R")
library(DMRcaller)

### create files vector
files = c(snakemake@input[['reports']])

### join biological replicates
control = lapply(files,aggregate)
names(control) = c(snakemake@wildcards[['sample']])
if (length(files) > 1){
	joinedControl = control[[1]]
	joinedControl = joinBio(control[-1],joinedControl)
}

save.image(snakemake@output[['Rdata']])
