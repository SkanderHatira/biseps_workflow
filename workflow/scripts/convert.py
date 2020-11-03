import pandas as pd
import sys

with open(snakemake.input[0],'r') as input , open(snakemake.output[0],'w')as output:
	bsp_report = pd.read_csv(input, sep="\t")
	converted = bsp_report[["chr","pos","strand","C_count","CT_count","context"]]
	converted.loc[:,'trinucleotide_context'] = "none"
	converted.to_csv(output,index=False,header=False,sep="\t")

