log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")
library(DMRcaller)
source( file.path(snakemake@scriptdir, 'common.R') ) # source from scripts directory
### create files vector
files = c(snakemake@input)
### join biological replicates
sample = lapply(files,aggregate)
### create conditions vector
condition = rep(snakemake@wildcards[['sample']],length(files))
if (length(files) > 1){
	joinedSample = sample[[1]]
	joinedSample = joinBio(sample[-1],joinedSample)
}	else {
	joinedSample = sample[[1]]
}

saveRDS(condition, snakemake@output[['conditionVector']])
saveRDS(joinedSample, snakemake@output[['rds']])


