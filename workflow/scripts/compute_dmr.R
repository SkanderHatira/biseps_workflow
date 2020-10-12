log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

# loading necessary packages
library(DMRcaller)
library(betareg)

#load data
control <- readRDS(snakemake@input[['control']])
treatment <- readRDS(snakemake@input[['treatment']])

# merge data in one dataframe
methylationData = joinReplicates(control,treatment)

#load data condtion vector
treatmentCondition = readRDS(snakemake@input[['treatmentConditionVector']])
controlCondition = readRDS(snakemake@input[['controlConditionVector']])
condition = c(treatmentCondition,controlCondition)
# compute DMR's with biological replicates , can only call bins/neighborhood methods
DMRsReplicatesNoiseFilter = computeDMRsReplicates(	methylationData = methylationData,
													condition = condition,
													regions = NULL,
													context = "CG",
													method = "bins",
													binSize = 100,
													test = "betareg",
													pseudocountM = 1,
													pseudocountN = 2,
													pValueThreshold = 0.01,
													minCytosinesCount = 4,
													minProportionDifference = 0.4,
													minGap = 0,
													minSize = 50,
													minReadsPerCytosine = 4,
													cores = snakemake@threads[[1]]
												)


save.image(snakemake@output[['rdata']])
