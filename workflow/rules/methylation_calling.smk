rule read_report:
	input:
		get_CX_reports,
	output:
		rds=outdir+"results/methylation_calling/{sample}-TechRep_{techrep}/{sample}-report.rds",
		conditionVector=outdir+"results/methylation_calling/{sample}-TechRep_{techrep}/{sample}-vector.rds"
	conda:
		"../envs/dmrcaller.yaml"
	log:
		outdir+"logs/methylation_calling/{sample}-{techrep}.log"
	resources:
		mem_mb= int(genomeSize*11),
		time_min=1440
	script:
		"../scripts/read_report.R"
