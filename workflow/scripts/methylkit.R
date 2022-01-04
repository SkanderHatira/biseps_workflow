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
minDiff <- snakemake@params[["minDiff"]]
qValue <- snakemake@params[["qValue"]]

### create output directory if it doesn't already exist
dir.create(file.path(outdir), showWarnings = FALSE)
### reading bismark's CX reports, by default using the tabix database for minimal memory usage
readingReports=methRead(files,
           sample.id=as.list(c(rep(sprintf("control%s", c(1:length(control)) )),rep(sprintf("treatment%s", c(1:length(treatment)) )))),
           assembly="bismark",
           treatment=c(rep(0,length(control)),rep(1,length(treatment))),
           context=context,
           mincov = minCov,
           pipeline="bismarkCytosineReport",
           dbtype = "tabix",
           dbdir = snakemake@output[["methylDB"]]
           )


### meth stats and plot ###
fileTxt<-file(snakemake@output[["methylationStatsTxt"]])
sink(fileTxt)
for (i in 1:length(files)) {
	writeLines(sprintf("methylation stats for %s",readingReports[[i]]@sample.id))
    getMethylationStats(readingReports[[i]],plot=FALSE,both.strands=FALSE)
    }
sink()
close(fileTxt)

pdf(snakemake@output[["methylationStatsPdf"]])
for (i in 1:length(files)) {
    getMethylationStats(readingReports[[i]],plot=TRUE,both.strands=FALSE)
    }
dev.off()

### coverage stats and plot ###
fileTxt<-file(snakemake@output[["coverageStatsTxt"]])
sink(fileTxt)
for (i in 1:length(files)) {
	writeLines(sprintf("methylation coverage stats for %s",readingReports[[i]]@sample.id))
    getCoverageStats(readingReports[[i]],plot=FALSE,both.strands=FALSE)
    }
sink()
close(fileTxt)

pdf(snakemake@output[["coverageStatsPdf"]])
for (i in 1:length(files)) {
    getCoverageStats(readingReports[[i]],plot=TRUE,both.strands=FALSE)
    }
dev.off()

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



all <- getMethylDiff(methDiff,difference=minDiff,qvalue=qValue)
fileTxt<-file(snakemake@output[["overAllMethylation"]])
sink(fileTxt)
all
sink()
close(fileTxt)
cols <- c("seqnames","start","end","width","strand")
my.gr <-as(all,"GRanges")
df <- data.frame(my.gr)
my.gr2 <-as(meth,"GRanges")
df2 <- data.frame(my.gr2)
print(head(df2))
print(head(df))
merged <- merge(df,df2,by = cols , all =F)
sorted <- merged[order("seqnames"),]

write.table(sorted, file=snakemake@output[["overAllMethylationBed"]], quote=F, sep="\t", row.names=F, col.names=F)

