rule read_control:
	input:
		expand("results/methylation_extraction/v31-{biorep}/v31-{biorep}_alignment.deduplicated.CX_report.txt",biorep=[1,2,3,4])
	output:
		rdata="results/methylation_calling/read_control.Rdata",
	conda:
		"../envs/dmrcaller.yaml"
	log:
		"logs/methylation_calling/read_control.log"
	params:
		
	threads:
		4
	script:
		"../scripts/read_control.R 2> {log}"
rule read_reports:
	input:
		reports=get_CX_reports,
		rdata=rules.read_control.output
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
		"../scripts/dmrcaller.R 2> {log}"
