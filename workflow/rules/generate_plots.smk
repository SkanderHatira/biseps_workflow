rule plots_dmrcaller:
	input:
		treatment=outdir+"results/methylation_calling/{treatment}-TechRep_{ttechrep}/{treatment}-{ttechrep}-report.rds",
		control=outdir+"results/methylation_calling/{control}-TechRep_{ctechrep}/{control}-{ctechrep}-report.rds",
	output:
		low_resolution_profiles= report(outdir+"results/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}/{control}-{ctechrep}_vs_{treatment}-{ttechrep}_low_resolution_profiles.pdf",category='plots'),
		methylation_data_coverage= report(outdir+"results/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}/{control}-{ctechrep}_vs_{treatment}-{ttechrep}_methylation_data_coverage.pdf",category='plots')
	conda:
		"../envs/dmrcaller.yaml"
	log:
		outdir+"logs/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}_plots_dmrcaller.log"
	script:
		"../scripts/plots.R"