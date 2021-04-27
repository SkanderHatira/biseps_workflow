#!/usr/bin/env Rscript
log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")
library("optparse")
library(DMRcaller)
library(betareg)
source( file.path(snakemake@scriptdir, 'common.R') )
option_list = list(
  make_option(c("-c", "--control"), type="character", default=NULL, 
              help="methylation CX report from bismark for the control", metavar="path"),
    

                make_option(c("-t", "--treatment"), type="character", default=NULL, 
              help="methylation CX report from bismark for the treatment", metavar="path"),
    make_option(c("-o", "--out"), type="character", default="output.txt", 
              help="output file name [default= %default]", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(snakemake@input[['control']])){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}
### create files vector
controlFiles = c(unlist(strsplit(snakemake@input[['control']], split=",")))
controlFiles
### join biological replicates
control = lapply(controlFiles,aggregate)
### create conditions vector
if (length(controlFiles) > 1){
	joinedControl = control[[1]]
	joinedControl = joinBio(control[-1],joinedControl)
}	else {
	joinedControl = control[[1]]
}

treatmentFiles = c(unlist(strsplit(snakemake@input[['treatment']], split=",")))
treatmentFiles
### join biological replicates
treatment = lapply(treatmentFiles,aggregate)
### create conditions vector
if (length(treatmentFiles) > 1){
	joinedtreatment = treatment[[1]]
	joinedtreatment = joinBio(treatment[-1],joinedtreatment)
}	else {
	joinedtreatment = treatment[[1]]
}
# control <- readRDS(snakemake@input[['control']])
# treatment <- readRDS(snakemake@input[['treatment']])
# treatmentCondition = readRDS(gsub("report", "vector", snakemake@input[['control']]))
# controlCondition = readRDS(gsub("report", "vector",snakemake@input[['treatment']]))

controlCondition = rep("control",length(controlFiles))
treatmentCondition = rep("treatment",length(treatmentFiles))


if( (length(controlCondition) >= 2) & (length(treatmentCondition) >= 2 )) {
  print("2 Bioreps at least")
  methylationData <- joinReplicates(joinedControl,joinedtreatment)
  DMRs <- computeDMRsReplicates(methylationData = methylationData,
    condition= c(controlCondition,treatmentCondition),
    regions = NULL,
    context = "CG",
    method = "bins",
    binSize = 1000,
    test = "betareg",
    pseudocountM = 1,
    pseudocountN = 2,
    pValueThreshold = 0.01,
    minCytosinesCount = 4,
    minProportionDifference = 0.4,
    minGap = 0,
    minSize = 50,
    minReadsPerCytosine = 4,
    cores = 6)
DMRs

  #  with at least 2 bioreps in both conditions
  } else if ( (length(controlCondition) = 1) & (length(controlCondition) = 1 )){
  # with no bio reps in both conditions
    print("no Bioreps ")

  DMRs <- computeDMRs(joinedControl,
joinedtreatment,
context = "CG",
method = "neighbourhood",
test = "score",
pValueThreshold = 0.01,
minCytosinesCount = 1 ,
minProportionDifference = 0.4,
minGap = 10,
minSize = 1,
minReadsPerCytosine = 5,
cores = 6)

DMRs

} else {print("There's something wrong with your input Data")}


df <- data.frame(DMRs)

write.table(df, file=snakemake@output[['output']], quote=F, sep="\t", row.names=F, col.names=F)
