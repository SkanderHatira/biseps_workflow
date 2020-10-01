rule alignment_pe:
	input:
		rules.genome_preparation.output,
		unpack(get_trimmed)
	output:
		bam='results/alignment/{sample}{lane}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}_bismark_bt2.bam'
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/alignment/{sample}{lane}{techrep}/{biorep}/align.log"
	params:
		#genome_directory
		genome= config['resources']['ref']['genome_directory'],
		basename= '{sample}{lane}{techrep}-{biorep}_bismark_bt2',
		# bismark parameters
		bismark= "-N 1 -L 20 -score_min L,0,-0.6",
		aligner= config["params"]["bismark"]["aligner"],
		out_dir= "results/alignment/{sample}{lane}{techrep}-{biorep}/",
		# aligners parameters (see manual)
		aligner_options= "",
		# optional parameters
		extra=""
	threads:
		4
	# -p is for the aligner , --parallel for bismark
	benchmark:
		"benchmarks/alignment/{sample}{lane}{techrep}-{biorep}.tsv"
	shell:
		"bismark --{params.aligner} {params.bismark} -p {threads} --parallel {threads} -1 {input.r1} -2 {input.r2} --bam {params.aligner_options} {params.extra} {params.genome} -o {params.out_dir} -B {params.basename} 2> {log}"

rule merge_convert:
	input:
		get_bam
	output:
		"results/alignment/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_alignment.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/alignment/{sample}{techrep}/{biorep}/bam_to_sam.log"
	params:
		extra=""
	threads:
		4
	shell:
		"samtools merge  {output} {input} -O SAM {params.extra} -@ {threads} 2> {log}"

rule deduplicate:
	input:
		rules.merge_convert.output
	output:
		"results/alignment/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_alignment.deduplicated.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/alignment/{sample}{techrep}/{biorep}/deduplicate.log"
	params:
		basename="{sample}{techrep}-{biorep}_alignment", #not compatible with multiple mode
		outdir="results/alignment/{sample}{techrep}-{biorep}/",
		extra="" 
	shell:
		"deduplicate_bismark {input} -o {params.basename} --output_dir {params.outdir} --sam 2> {log}"
