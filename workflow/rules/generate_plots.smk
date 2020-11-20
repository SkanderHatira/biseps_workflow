rule plots_dmrcaller:
	input:
		treatment="results/methylation_calling/{treatment}-TechRep_{ttechrep}/{treatment}-{ttechrep}-report.rds",
		control="results/methylation_calling/{control}-TechRep_{ctechrep}/{control}-{ctechrep}-report.rds",
	output:
		low_resolution_profiles= report("results/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}/{control}-{ctechrep}_vs_{treatment}-{ttechrep}_low_resolution_profiles.svg",category='plots'),
		methylation_data_coverage= report("results/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}/{control}-{ctechrep}_vs_{treatment}-{ttechrep}_methylation_data_coverage.svg",category='plots')
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/{control}-{ctechrep}_vs_{treatment}-{ttechrep}_plots_dmrcaller.log"
	threads:
		1
	script:
		"../scripts/plots.R"