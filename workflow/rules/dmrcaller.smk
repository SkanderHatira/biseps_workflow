rule methylation_extraction_pe:
	input:
		conditionTech=expand("results/methylation_extraction/{sample}-{{biorep}}_alignment.deduplicated.CX_report.txt", sample=get_replicate_list(units)),
		conditionBio=expand("results/methylation_extraction/{{sample}}-{biorep}_alignment.deduplicated.CX_report.txt")
		control= expand("results/methylation_extraction/{sample}-{biorep}", sample=[3-1-1] ,replicate=get_replicate_list(units))	
	output:
		rdata="results/methylation_calling/control_vs_{sample}.Rdata",
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/{sample}.log"
	params:
		
	threads:
		4
	script:
		"../scripts/dmrcaller.R"
