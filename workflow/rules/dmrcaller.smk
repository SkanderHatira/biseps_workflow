# rule read_control:
# 	input:
# 		expand("results/methylation_extraction/{{control}}{{ctechrep}}-{cbiorep}/{{control}}{{ctechrep}}-{cbiorep}_merged.deduplicated.CX_report.txt",cbiorep=get_control_bioreps())
# 	output:
# 		rdata="results/methylation_calling/{control}{ctechrep}_read_control.Rdata"
# 	conda:
# 		"../envs/dmrcaller.yaml"
# 	log:
# 		"logs/methylation_calling/{control}{ctechrep}_read_control.log"
# 	params:
		
# 	threads:
# 		4
# 	script:
# 		"../scripts/read_control.R 2> {log}"
# rule read_reports:
# 	input:
# 		reports=get_CX_reports,
# 		rdata=rules.read_control.output
# 	output:
# 		"results/methylation_calling/{control}{ctechrep}_vs_{sample}{techrep}.Rdata"
# 	conda:
# 		"../envs/dmrcaller.yaml"
# 	log:
# 		"logs/methylation_calling/{control}{ctechrep}_vs_{sample}{techrep}.log"
# 	params:
		
# 	threads:
# 		4
# 	script:
# 		"../scripts/dmrcaller.R 2> {log}"

rule read_report:
	input:
		get_CX_reports,
	output:
		rds="results/methylation_calling/report_GRanges/{sample}{techrep}.rds"
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/{sample}{techrep}.log"
	params:
		
	threads:
		4
	script:
		"../scripts/read_report.R"


rule comparison:
	input:
		treatment="results/methylation_calling/report_GRanges/{treatment}{ttechrep}.rds",
		control="results/methylation_calling/report_GRanges/{control}{ctechrep}.rds"
	output:
		rdata="results/methylation_calling/comparison/{control}{ctechrep}_vs_{treatment}{ttechrep}.Rdata"
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/{control}{ctechrep}_vs_{treatment}{ttechrep}.log"
	script:
		"../scripts/compute_dmr.R"	
