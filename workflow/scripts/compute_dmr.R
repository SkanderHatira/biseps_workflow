log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library(DMRcaller)
#load data
control <- readRDS(snakemake@input[['control']])
treatment <- readRDS(snakemake@input[['treatment']])

save.image(snakemake@output[['rdata']])
