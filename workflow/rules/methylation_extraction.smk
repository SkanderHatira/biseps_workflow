rule methylation_extraction_bismark:
	input:
		rules.deduplicate.output
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-sorted.deduplicated.CX_report.txt"
	conda:
		"../envs/bisgraph.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-methylation_extraction_bismark.log"
	params:
		#genome directory
		genome=get_abs(config['resources']['ref']['genome']),
		# optional parameters
		out_dir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		extra="--comprehensive" #include_overlap? #get_p_s_flag?
	threads:
		2
	shell:
		"bismark_methylation_extractor  {input} --bedGraph --CX --cytosine_report --genome_folder {params.genome} -p  --parallel {threads} -o {params.out_dir} {params.extra} &> {log} "

rule methylation_extraction_bsmap:
	input:
		rules.deduplicate.output
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bsmap/{sample}-bsmap_report.txt"
	conda:
		"../envs/bsmap.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-methylation_extraction_bsmap.log"
	params:
		#genome directory
		genome= config['params']['bsmap']['genome'],
		# optional parameters
		extra=""
	threads:
		2
	shell:
		"methratio.py --remove-duplicate -z -d {params.genome} -o {output} -p {input}  &> {log}"

rule bsp_to_cx:
	input:
		rules.methylation_extraction_bsmap.output
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bsmap/{sample}-bsmap_CX_report.txt"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-bsp_to_cx.log"
	threads:
		1
	script:
		"../scripts/convert.py"