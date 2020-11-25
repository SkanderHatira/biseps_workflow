log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

# loading necessary packages
library(DMRcaller)
library(betareg)
library(ggplot2)
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
condition = c(controlCondition,treatmentCondition)
pdf(file = snakemake@output[['ggplot']], width = 14)
ggplot(data=df,aes(y=readsM1/readsN1,x=start,fill=context,col=context))+geom_point()
dev.off()

# compute DMR's with biological replicates , can only call bins method
DMRsReplicatesBins = computeDMRsReplicates(	methylationData = methylationData,
													condition = condition,
													regions = NULL,
													context = "CG",
													method = "bins",
													binSize = 200,
													test = "betareg",
													pseudocountM = 0,
													pseudocountN = 0,
													pValueThreshold = 0.01,
													minCytosinesCount = 4,
													minProportionDifference = 0.4,
													minGap = 0,
													minSize = 50,
													minReadsPerCytosine = 4,
													cores = snakemake@threads[[1]]
												)
# compute DMR's with biological replicates , can only call neighborhood method

DMRsReplicatesNeighbourhood = computeDMRsReplicates(	methylationData = methylationData,
													condition = condition,
													regions = NULL,
													context = "CG",
													method = "neighbourhood",
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
saveRDS(DMRsReplicatesBins, snakemake@output[['rds']])
save.image(snakemake@output[['rdata']])

