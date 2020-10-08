rule methylation_extraction_pe:
	input:
		rules.deduplicate.output
	output:
		"results/methylation_extraction/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_alignment.deduplicated.CX_report.txt"
	conda:
		"../envs/bisgraph.yaml"
	log:
		"logs/methylation_extraction/{sample}{techrep}-{biorep}.log"
	params:
		#genome directory
		genome=config['resources']['ref']['genome_directory'],
		# optional parameters
		out_dir="results/methylation_extraction/{sample}{techrep}-{biorep}/",
		extra="--comprehensive" #include_overlap? #get_p_s_flag?
	threads:
		8
	shell:
		"bismark_methylation_extractor  {input} --bedGraph --CX --cytosine_report --genome_folder .test/resources/genome -p  --parallel {threads} -o {params.out_dir} {params.extra} 2> {log}; pwd &>> {log}"
