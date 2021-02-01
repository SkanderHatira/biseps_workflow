rule read_report:
	input:
		get_CX_reports,
	output:
		rds=temp(outdir+"results/methylation_calling/{sample}-TechRep_{techrep}/{sample}-{techrep}-report.rds"),
		conditionVector=temp(outdir+"results/methylation_calling/{sample}-TechRep_{techrep}/{sample}-{techrep}-vector.rds")
	conda:
		"../envs/dmrcaller.yaml"
	log:
		outdir+"logs/methylation_calling/{sample}-{techrep}.log"
	resources:
		mem_mb= int(genomeSize*11),
		time_min=1440
	script:
		"../scripts/read_report.R"


rule pairwise_reports:
	input:
		treatment=outdir+"results/methylation_calling/{treatment}-TechRep_{ttechrep}/{treatment}-{ttechrep}-report.rds",
		treatmentConditionVector=outdir+"results/methylation_calling/{treatment}-TechRep_{ttechrep}/{treatment}-{ttechrep}-vector.rds",
		control=outdir+"results/methylation_calling/{control}-TechRep_{ctechrep}/{control}-{ctechrep}-report.rds",
		controlConditionVector=outdir+"results/methylation_calling/{control}-TechRep_{ctechrep}/{control}-{ctechrep}-vector.rds"
	output:
		rdata=outdir+"results/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}/{control}-{ctechrep}_vs_{treatment}-{ttechrep}.Rdata",
	conda:
		"../envs/dmrcaller.yaml"
	log:
		outdir+"logs/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}.log"
	resources:
		mem_mb= int(genomeSize*11),
		time_min=1440
	script:
		"../scripts/pairwise_reports.R"
