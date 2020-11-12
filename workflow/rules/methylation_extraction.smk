rule methylation_extraction_bismark:
	input:
		rules.deduplicate.output[0]
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.CX_report.txt",
		'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated_splitting_report.txt',
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.M-bias.txt"
	conda:
		"../envs/bisgraph.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-methylation_extraction_bismark.log"
	params:
		#genome directory
		genome=get_abs(config['resources']['ref']['genome']),
		# optional parameters
		out_dir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		instances= config['params']['bismark']['instances'],
		extra="--comprehensive" #include_overlap? #get_p_s_flag?
	threads:
		4*config['params']['bismark']['instances']
	shell:
		"bismark_methylation_extractor  {input} --bedGraph --CX --cytosine_report --genome_folder {params.genome} -p  --parallel {params.instances} -o {params.out_dir} {params.extra} 2> {log} "