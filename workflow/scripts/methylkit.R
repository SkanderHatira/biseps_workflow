library(methylKit)


### getting files ###
control = c(unlist(strsplit(snakemake@input[['control']], split=",")))
treatment = c(unlist(strsplit(snakemake@input[['treatment']], split=",")))
files  <- as.list(c(control, treatment))


### params ###


context <- "CpG" #snakemake@params[["context"]]
bins <- TRUE #snakemake@params[["bins"]]
species <- "Malus_Domestica" #snakemake@params[["species"]]
outdir <- "results" #snakemake@params[["outdir"]]
cores <- 4 #snakemake@resources[["cpus"]]
windowSize <-1000 #snakemake@params[["windowSize"]]
stepSize <- 1000 #snakemake@params[["stepSize"]]
minCov <- 4  #snakemake@params[["minCov"]]
overdispersion <- "none" # default none, NM for overdispersion #snakemake@params[["overdispersion"]]
testOverdispersion <- "F" # default F, Chisq for overdispersion  #snakemake@params[["test"]]
## filters dmr's ###
minDiff <- 0.25 #snakemake@params[["minDiff"]]
qValue <- 0.01 #snakemake@params[["qValue"]]

### inferred params  ###
method <- if(bins) "bins" else "bases"
