rule read_reports:
	input:
		unpack(get_CX_reports)	
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
