rule methylation_extraction_pe:
	input:
		"results/alignment/{sample}{lane}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}_alignment.deduplicated.sam"
	output:
		file=touch("results/methylation_extraction/{sample}{lane}{techrep}-{biorep}/extraction.txt"),
		dir=directory("results/methylation_extraction/{sample}{lane}{techrep}-{biorep}/")
	conda:
		"../envs/bisgraph.yaml"
	log:
		"logs/methylation_extraction/{sample}{lane}{techrep}-{biorep}.log"
	params:
		#genome directory
		genome=config['resources']['ref']['genome_directory'],
		# optional parameters
		extra="--comprehensive" #include_overlap? #get_p_s_flag?
	threads:
		8
	shell:
		"bismark_methylation_extractor  {input} --bedGraph --CX --cytosine_report --genome_folder {params.genome} -p  --parallel {threads} -o {output.dir} {params.extra}"
