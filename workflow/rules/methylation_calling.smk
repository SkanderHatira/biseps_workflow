rule read_report:
	input:
		get_CX_reports,
	output:
		rds="results/methylation_calling/report_GRanges/report_{sample}{techrep}.rds",
		conditionVector="results/methylation_calling/report_GRanges/conditionVector_{sample}{techrep}.rds"
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/{sample}{techrep}.log"
	threads:
		4
	script:
		"../scripts/read_report.R"


rule comparison:
	input:
		treatment="results/methylation_calling/report_GRanges/report_{treatment}{ttechrep}.rds",
		treatmentConditionVector="results/methylation_calling/report_GRanges/conditionVector_{treatment}{ttechrep}.rds",
		control="results/methylation_calling/report_GRanges/report_{control}{ctechrep}.rds",
		controlConditionVector="results/methylation_calling/report_GRanges/conditionVector_{control}{ctechrep}.rds"
	output:
		rdata="results/methylation_calling/comparison/{control}{ctechrep}_vs_{treatment}{ttechrep}.Rdata",
		Meth_profile_genome_wide="results/methylation_calling/plots/{control}{ctechrep}_vs_{treatment}{ttechrep}_Genome_Wide_Meth_Profile.png",
		Meth_coverage="results/methylation_calling/plots/{control}{ctechrep}_vs_{treatment}{ttechrep}_Meth_Coverage.png"
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/{control}{ctechrep}_vs_{treatment}{ttechrep}.log"
	threads:
		2
	params:
		
	script:
		"../scripts/compute_dmr.R"
