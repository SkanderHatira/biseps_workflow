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

# # plot coverage in different contexts
# pdf(snakemake@output[['Meth_coverage']])
# plotMethylationDataCoverage(control,
# treatment,
# breaks = c(1,5,10,15),
# regions = NULL,
# conditionsNames=c("control","treatment"),
# context = contexts,
# proportion = TRUE,
# labels=LETTERS,
# contextPerRow = FALSE)
# dev.off()

# # Plot Methylation Profile : Context Specific Global changes (10000 bp window)
# pdf(snakemake@output[['Meth_profile_genome_wide']])
# plotMethylationProfileFromData(control,
# 	treatment,
# 	conditionsNames = c("control","treatment"),
# 	windowSize = 10000,
# 	autoscale = FALSE,
# 	context = "CG")
# dev.off()



# compute DMR's with biological replicates , can only call bins method
DMRsReplicatesBins = computeDMRsReplicates(	methylationData = methylationData,
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

save.image(snakemake@output[['rdata']])

