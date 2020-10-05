
library(DMRcaller)
#load data
methylationData <- readBismarkPool(c(snakemake@input))


save.image(snakemake@output[['rdata']])
