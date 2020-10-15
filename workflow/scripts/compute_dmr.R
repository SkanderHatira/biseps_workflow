log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

# loading necessary packages
library(DMRcaller)
library(betareg)
source( file.path(snakemake@scriptdir, 'common.R') ) # source from scripts directory

#load data
control <- readRDS(snakemake@input[['control']])
treatment <- readRDS(snakemake@input[['treatment']])

# merge data in one dataframe
methylationData = joinReplicates(control,treatment)
# defining methylation contexts
contexts = c("CG","CHG","CHH")

#load data condtion vector
treatmentCondition = readRDS(snakemake@input[['treatmentConditionVector']])
controlCondition = readRDS(snakemake@input[['controlConditionVector']])
condition = c(controlCondition,treatmentCondition)

# plot coverage in different contexts
png(snakemake@output[['Meth_coverage']], width = 3200, height = 2400,res = 350)
plotMethylationDataCoverage(control,
treatment,
breaks = c(1,5,10,15),
regions = NULL,
conditionsNames=c("control","treatment"),
context = contexts,
proportion = TRUE,
labels=LETTERS,
contextPerRow = FALSE)
dev.off()

# Plot Methylation Profile : Context Specific Global changes (10000 bp window)
png(snakemake@output[['Meth_profile_genome_wide']], width = 3200, height = 2400,res = 350)
plotMethylationProfileFromData(control,
	treatment,
	conditionsNames = c("control","treatment"),
	windowSize = 10000,
	autoscale = FALSE,
	context = c("CG"))
dev.off()
# compute DMR's with biological replicates , can only call bins/neighborhood methods
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

# generate colours scale for treatment and control
# Ccolor = colorRampPalette(c("red","green"))(length(controlCondition)) #control
# Tcolor = colorRampPalette(c("blue","yellow"))(length(treatmentCondition))  #treatment
# colors = c(Ccolor,Tcolor)

# transform GenomicRanges to data frame for easier manipulation
df = data.frame(methylationData)

save.image(snakemake@output[['rdata']])

