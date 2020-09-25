rule alignment_pe:
	input:
		rules.genome_preparation.output,
		unpack(get_trimmed)
	output:
		bam='results/alignment/{sample}{lane}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}-1_bismark_bt2_pe.bam',
		report='results/alignment/{sample}{lane}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}-1_bismark_bt2_PE_report.txt',
		dir=directory("results/alignment/{sample}{lane}{techrep}-{biorep}/")
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/alignment/{sample}{lane}{techrep}/{biorep}/align.log"
	params:
		#genome_directory
		genome= config['resources']['ref']['genome_directory'],
		prefix= 'results/alignment/{sample}{lane}{techrep}-{biorep}/',
		# bismark parameters
		bismark= "-N 1 -L 20 -score_min L,0,-0.6",
		aligner= config["params"]["bismark"]["aligner"],
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
		"bismark --{params.aligner} {params.bismark} -p {threads} --parallel {threads} -1 {input.r1} -2 {input.r2} --bam {params.aligner_options} {params.extra} {params.genome} -o {output.dir}"

rule bam_to_sam:
	input:
		get_bam
	output:
		"results/alignment/{sample}{lane}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}_alignment.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/alignment/{sample}{lane}{techrep}/{biorep}/bam_to_sam.log"
	params:
		extra=""
	shell:
		"samtools view -h -o {output} {input} {params.extra}"

rule deduplicate:
	input:
		rules.bam_to_sam.output
	output:
		"results/alignment/{sample}{lane}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}_alignment.deduplicated.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/alignment/{sample}{lane}{techrep}/{biorep}/deduplicate.log"
	params:
		basename="{sample}{lane}{techrep}-{biorep}_alignment", #not compatible with multiple mode
		outdir="results/alignment/{sample}{lane}{techrep}-{biorep}/",
		extra="" 
	shell:
		"deduplicate_bismark {input} -o {params.basename} --output_dir {params.outdir} --sam"
