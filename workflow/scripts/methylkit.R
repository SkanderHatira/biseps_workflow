library(methylKit)


### getting files ###
control = c(unlist(strsplit(snakemake@input[['control']], split=",")))
treatment = c(unlist(strsplit(snakemake@input[['treatment']], split=",")))
files  <- as.list(c(control, treatment))

### params ###


context <- snakemake@wildcards[["context"]]
bins <- snakemake@params[["bins"]]
species <- "Malus_Domestica" #snakemake@params[["species"]]
outdir <- snakemake@params[["outdir"]]
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

### create output directory if it doesn't already exist
dir.create(file.path(outdir), showWarnings = FALSE)
### reading bismark's CX reports, by default using the tabix database for minimal memory usage
readingReports=methRead(files,
           sample.id=as.list(c(rep("control",length(control)),rep("treatment",length(treatment)))),
           assembly="bismark",
           treatment=c(rep(0,length(control)),rep(1,length(treatment))),
           context=context,
           mincov = minCov,
           pipeline="bismarkCytosineReport",
           dbtype = "tabix",
           dbdir = "methylDB"
           )


### meth stats and plot ###
for (i in 1:length(files)) {
	fileTxt<-file(snakemake@output[["methylationStatsTxt"]])
    sink(fileTxt)
    getMethylationStats(readingReports[[i]],plot=FALSE,both.strands=FALSE)
    sink()
    close(fileTxt)
	pdf(snakemake@output[["methylationStatsPdf"]])
    getMethylationStats(readingReports[[i]],plot=TRUE,both.strands=FALSE)
    dev.off()
    }

### coverage stats and plot ###
for (i in 1:length(files)) {
	fileTxt<-file(snakemake@output[["coverageStatsTxt"]])
    sink(fileTxt)
    getCoverageStats(readingReports[[i]],plot=FALSE,both.strands=FALSE)
    sink()
    close(fileTxt)
	pdf(snakemake@output[["coverageStatsPdf"]])
    getCoverageStats(readingReports[[i]],plot=TRUE,both.strands=FALSE)
    dev.off()
    }

