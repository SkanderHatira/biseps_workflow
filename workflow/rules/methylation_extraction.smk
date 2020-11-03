rule methylation_extraction_bismark:
	input:
		rules.deduplicate.output
	output:
		"results/methylation_extraction_bismark/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_merged.deduplicated.CX_report.txt"
	conda:
		"../envs/bisgraph.yaml"
	log:
		"logs/methylation_extraction_bismark/{sample}{techrep}-{biorep}.log"
	params:
		#genome directory
		genome=get_abs(config['resources']['ref']['genome_directory']),
		# optional parameters
		out_dir="results/methylation_extraction_bismark/{sample}{techrep}-{biorep}/",
		extra="--comprehensive" #include_overlap? #get_p_s_flag?
	threads:
		2
	shell:
		"bismark_methylation_extractor  {input} --bedGraph --CX --cytosine_report --genome_folder {params.genome} -p  --parallel {threads} -o {params.out_dir} {params.extra} &> {log} "

rule methylation_extraction_bsmap:
	input:
		get_bam_bsmap_pe
	output:
		"results/methylation_extraction_bsmap/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_bsmap_report.txt"
	conda:
		"../envs/bsmap.yaml"
	log:
		"logs/methylation_extraction_bsmap/{sample}{techrep}-{biorep}.log"
	params:
		#genome directory
		genome= config['params']['bsmap']['genome'],
		# optional parameters
		extra=""
	threads:
		2
	shell:
		"methratio.py -d {params.genome} -o {output} -p {input}  &> {log}"


rule bsp_to_cx:
	input:
		rules.methylation_extraction_bsmap.output
	output:
		"results/methylation_extraction_bsmap/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_bsmap_CX_report.txt"
	log:
		"logs/methylation_extraction_bsmap/{sample}{techrep}-{biorep}_conversion_to_cx.log"
	threads:
		1
	script:
		"../scripts/convert.py"