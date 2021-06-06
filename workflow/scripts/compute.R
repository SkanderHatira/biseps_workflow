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
contexts <- c("CG","CHG","CHH")
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


if ( (length(controlCondition) >= 2) & (length(treatmentCondition) >= 2 )) {
  print("2 Bioreps at least")
  methylationData <- joinReplicates(joinedControl,joinedtreatment)
  if ((snakemake@params[["method"]] == "bins") & (snakemake@params[["test"]] =="betareg")) {
	  	   print("bins with reps ")

  for (context in contexts) {
   DMRs <- computeDMRsReplicates(methylationData = methylationData,
    condition= c(controlCondition,treatmentCondition),
    regions = NULL,
    context = context,
    method = "bins",
    binSize = snakemake@params[["binSize"]],
    test = snakemake@params[["test"]],
    pseudocountM = snakemake@params[["pseudocountM"]],
    pseudocountN = snakemake@params[["pseudocountN"]],
    pValueThreshold = snakemake@params[["pValueThreshold"]],
    minCytosinesCount = snakemake@params[["minCytosinesCount"]],
    minProportionDifference =snakemake@params[["minProportionDifference"]],
    minGap = snakemake@params[["minGap"]],
    minSize = snakemake@params[["minSize"]],
    minReadsPerCytosine = snakemake@params[["minReadsPerCytosine"]],
    cores = snakemake@params[["cores"]])
	DMRs
	df <- data.frame(DMRs)

	write.table(df, file=snakemake@output[[context]], quote=F, sep="\t", row.names=F, col.names=F)
  }
  } else if ((snakemake@params[["method"]] =="neighbourhood") & (snakemake@params[["test"]] =="betareg")) {
	   print("neighbourhood with reps ")

  for (context in contexts) {
   DMRs <- computeDMRsReplicates(methylationData = methylationData,
    condition= c(controlCondition,treatmentCondition),
    regions = NULL,
    context = context,
    method = "neighbourhood",
    test = snakemake@params[["test"]],
    pseudocountM = snakemake@params[["pseudocountM"]],
    pseudocountN = snakemake@params[["pseudocountN"]],
    pValueThreshold = snakemake@params[["pValueThreshold"]],
    minCytosinesCount = snakemake@params[["minCytosinesCount"]],
    minProportionDifference =snakemake@params[["minProportionDifference"]],
    minGap = 10,
    minSize = 1,
    minReadsPerCytosine = snakemake@params[["minReadsPerCytosine"]],
    cores = snakemake@params[["cores"]])
DMRs
df <- data.frame(DMRs)

write.table(df, file=snakemake@output[[context]], quote=F, sep="\t", row.names=F, col.names=F)
  }
  } else {   
	   stop("with biological replicates you can either use bins or neighbourhood methods ")
	   }
 
  } else if ( (length(controlCondition) = 1) & (length(controlCondition) = 1 )){
	  
  # with no bio reps in both conditions
    print("no Bioreps ")
	
	if ((snakemake@params[["method"]] =="neighbourhood") ) {  for (context in contexts) {
		    print("neighbourhood no reps ")

  DMRs <- computeDMRs(joinedControl,
joinedtreatment,
context = context,
method = "neighbourhood",
test = snakemake@params[["test"]],
pValueThreshold = snakemake@params[["pValueThreshold"]],
minCytosinesCount = snakemake@params[["minCytosinesCount"]] ,
minProportionDifference = snakemake@params[["minProportionDifference"]],
minGap = snakemake@params[["minGap"]],
minSize = snakemake@params[["minSize"]],
minReadsPerCytosine = snakemake@params[["minReadsPerCytosine"]],
cores = snakemake@params[["cores"]])



df <- data.frame(DMRs)

write.table(df, file=snakemake@output[[context]], quote=F, sep="\t", row.names=F, col.names=F)
 }} else if (snakemake@params[["method"]] =="bins" ) {
	 		    print("bins no reps ")
 
	  for (context in contexts) {
  DMRs <- computeDMRs(joinedControl,
joinedtreatment,
context = context,
method = "bins",
binSize = snakemake@params[["binSize"]],
test = snakemake@params[["test"]],
pValueThreshold = snakemake@params[["pValueThreshold"]],
minCytosinesCount = snakemake@params[["minCytosinesCount"]] ,
minProportionDifference = snakemake@params[["minProportionDifference"]],
minGap = snakemake@params[["minGap"]],
minSize = snakemake@params[["minSize"]],
minReadsPerCytosine = snakemake@params[["minReadsPerCytosine"]],
cores = snakemake@params[["cores"]])



df <- data.frame(DMRs)

write.table(df, file=snakemake@output[[context]], quote=F, sep="\t", row.names=F, col.names=F)
 } } else if (snakemake@params[["method"]] =="noise_filter" ) {
 print("noise_filter no reps ")
for (context in contexts) {
  DMRs <- computeDMRs(joinedControl,
joinedtreatment,
context = context,
windowSize = snakemake@params[["binSize"]],
test = snakemake@params[["test"]],
kernelFunction = snakemake@params[["kernelFunction"]],
pValueThreshold = snakemake@params[["pValueThreshold"]],
minCytosinesCount = snakemake@params[["minCytosinesCount"]] ,
minProportionDifference = snakemake@params[["minProportionDifference"]],
minGap = snakemake@params[["minGap"]],
minSize = snakemake@params[["minSize"]],
minReadsPerCytosine = snakemake@params[["minReadsPerCytosine"]],
cores = snakemake@params[["cores"]],
method = "noise_filter",
)



df <- data.frame(DMRs)

write.table(df, file=snakemake@output[[context]], quote=F, sep="\t", row.names=F, col.names=F)}

}} else {print("There's something wrong with your input Data")}


