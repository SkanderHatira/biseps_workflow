log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library(DMRcaller)
#load data
control <- readRDS(snakemake@input[['control']])
treatment <- readRDS(snakemake@input[['treatment']])
contexts = c("CG","CHG","CHH")

pdf(snakemake@output[['low_resolution_profiles']])
for (c in contexts) {
	plotMethylationProfileFromData(control,
	treatment,
	conditionsNames = c(snakemake@wildcards[["control"]],snakemake@wildcards[["treatment"]]),
	windowSize = 10000,
	autoscale = FALSE,
	context = c(c))
}

dev.off()

pdf(snakemake@output[['methylation_data_coverage']])
for (c in contexts) {
	plotMethylationDataCoverage(control,
	treatment,
	breaks = c(1,5,10,15),
	regions = NULL,
	conditionsNames=c(snakemake@wildcards[["control"]],snakemake@wildcards[["treatment"]]),
	context = c(c),
	proportion = TRUE,
	labels=LETTERS,
	contextPerRow = FALSE)
}
dev.off()