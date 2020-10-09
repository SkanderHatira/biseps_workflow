# source("common.R")
# load(snakemake@input[['rdata']])
# library(DMRcaller)

# ### create files vector
# files = c(snakemake@input[['reports']])
# conditions= c("control",snakemake@wildcards[["sample"]])
# ### join biological replicates
# treatment = lapply(files,aggregate)
# names(treatment) = c(snakemake@wildcards[['sample']])
# if (length(files) > 1){
# 	joinedTreatment = treatment[[1]]
# 	joinedTreatment = joinBio(treatment[-1],joinedTreatment)
# }
# save.image(snakemake@output[['rdata']])
