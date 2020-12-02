log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

# loading necessary packages
library(DMRcaller)
source( file.path(snakemake@scriptdir, 'common.R') ) # source from scripts directory

#load data
control <- readRDS(snakemake@input[['control']])
treatment <- readRDS(snakemake@input[['treatment']])

# merge data in one dataframe
methylationData = joinReplicates(control,treatment)
df = data.frame(methylationData)

# defining methylation contexts
contexts = c("CG","CHG","CHH")

#load data condtion vector
treatmentCondition = readRDS(snakemake@input[['treatmentConditionVector']])
controlCondition = readRDS(snakemake@input[['controlConditionVector']])
conditions = c(controlCondition,treatmentCondition)

save.image(snakemake@output[['rdata']])

