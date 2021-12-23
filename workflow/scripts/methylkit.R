library(methylKit)


### getting files ###
control = c(unlist(strsplit(snakemake@input[['control']], split=",")))
treatment = c(unlist(strsplit(snakemake@input[['treatment']], split=",")))
files  <- as.list(c(control, treatment))

### params ###


context <- snakemake@wildcards[["context"]]
method <- snakemake@params[["method"]]
species <- snakemake@params[["species"]]
outdir <- snakemake@params[["outdir"]]
cores <- snakemake@resources[["cpus"]]
windowSize <-snakemake@params[["windowSize"]]
stepSize <- snakemake@params[["stepSize"]]
minCov <- snakemake@params[["minCov"]]
overdispersion <- snakemake@params[["overdispersion"]]
testOverdispersion <- snakemake@params[["test"]]
## filters dmr's ###
minDiff <- 0.25 #snakemake@params[["minDiff"]]
qValue <- 0.01 #snakemake@params[["qValue"]]


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
           dbdir = snakemake@output[["methylDB"]]
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

### mergin samples ### depends on method bins/base_level

if (method == "bins") {
    tiles = tileMethylCounts(readingReports,win.size=windowSize,step.size=stepSize,cov.bases = minCov)
    meth=unite(tiles, destrand=FALSE)
} else {
    meth=unite(readingReports, destrand=FALSE) # destrand TRUE =  merge methylation on different strands , default : FALSE 
                                  			   # by default takes only bases/regions covered in all samples (can be altered)
}


fileTxt<-file(snakemake@output[["correlationTxt"]])
sink(fileTxt)
getCorrelation(meth,plot=FALSE)
sink()
close(fileTxt)
pdf(snakemake@output[["correlationPdf"]])
getCorrelation(meth,plot=TRUE)
dev.off()


pdf(snakemake@output[["clustersPdf"]])
clusterSamples(meth, dist="correlation", method="ward.D2", plot=TRUE)
dev.off()
### PCA ###
pdf(snakemake@output[["pcaScreePdf"]])
PCASamples(meth, screeplot=TRUE)
dev.off()


pdf(snakemake@output[["pcaPdf"]])
PCASamples(meth)
dev.off()
print(meth)

### calculating differential methylation ###
methDiff=calculateDiffMeth(meth,mc.cores=cores)


### filtering differential methylation ###
fileTxt<-file(snakemake@output[["hyperMethylation"]])
hyper <- getMethylDiff(methDiff,difference=minDiff,qvalue=qValue,type="hyper")
sink(fileTxt)
hyper
sink()
close(fileTxt)

my.gr=as(hyper,"GRanges")
df <- data.frame(my.gr)
write.table(df, file=snakemake@output[["hyperMethylationBed"]], quote=F, sep="\t", row.names=F, col.names=F)

hypo <- getMethylDiff(methDiff,difference=minDiff,qvalue=qValue,type="hypo")
fileTxt<-file(snakemake@output[["hypoMethylation"]])
sink(fileTxt)
hypo 
sink()
close(fileTxt)

my.gr=as(hypo,"GRanges")
df <- data.frame(my.gr)
write.table(df, file=snakemake@output[["hypoMethylationBed"]], quote=F, sep="\t", row.names=F, col.names=F)

all <- getMethylDiff(methDiff,difference=minDiff,qvalue=qValue)
fileTxt<-file(snakemake@output[["overAllMethylation"]])
sink(fileTxt)
all
sink()
close(fileTxt)

my.gr=as(all,"GRanges")
df <- data.frame(my.gr)
write.table(df, file=snakemake@output[["overAllMethylationBed"]], quote=F, sep="\t", row.names=F, col.names=F)
