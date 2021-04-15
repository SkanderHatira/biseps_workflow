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
	script:
		"../scripts/read_report.R"
