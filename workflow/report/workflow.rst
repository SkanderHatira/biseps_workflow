This is a snakemake pipeline for bisulfite sequencing data, it implements:
1. 	Adapter trimming and quality check
2.	Quality reports and statistics (fastqc+ multiqc)
3.	Methylation extraction with bismark (bowtie2/hisat2 as aligners)
4.	DMR identification with dmraller (in all contexts) : in progress
