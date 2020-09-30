rule read_reports:
	input:
		unpack(get_CX_reports)	
	output:
		rdata="results/methylation_calling/control_vs_{sample}{techrep}.Rdata",
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/{sample}{techrep}.log"
	params:
		
	threads:
		4
	script:
		"../scripts/dmrcaller.R"
