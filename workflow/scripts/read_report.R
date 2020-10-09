log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")
library(DMRcaller)
source( file.path(snakemake@scriptdir, 'common.R') ) # source from scripts directory
### create files vector
files = c(snakemake@input)
print(files)
### join biological replicates
sample = lapply(files,aggregate)

print(names(sample))
if (length(files) > 1){
	joinedSample = sample[[1]]
	joinedSample = joinBio(sample[-1],joinedSample)
}
names(joinedSample) = c(snakemake@wildcards[['sample']])

saveRDS(joinedSample, snakemake@output[['rds']])


