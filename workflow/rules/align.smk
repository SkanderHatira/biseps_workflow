rule alignment_pe:
	input:
		rules.genome_preparation.output,
		unpack(get_trimmed)
	output:
		bam='results/alignment/{sample}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}_bismark_bt2_pe.bam',
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/alignment/{sample}{lane}{techrep}-{biorep}/align.log"
	params:
		#genome_directory
		genome= config['resources']['ref']['genome_directory'],
		basename= '{sample}{lane}{techrep}-{biorep}_bismark_bt2',
		# bismark parameters
		bismark= "-N 1 -L 20 -score_min L,0,-0.6",
		aligner= config["params"]["bismark"]["aligner"],
		temp='results/alignment/{sample}{techrep}-{biorep}/temp/',
		out_dir= "results/alignment/{sample}{techrep}-{biorep}/",
		# aligners parameters (see manual)
		aligner_options= "",
		# optional parameters
		extra=""
	threads:
		2
	# -p is for the aligner , --parallel for bismark
	benchmark:
		"benchmarks/alignment/{sample}{lane}{techrep}-{biorep}.tsv"
	shell:
		"bismark --{params.aligner} {params.bismark}  --bam {params.aligner_options} {params.extra} "
		"--temp_dir {params.temp}  -o {params.out_dir} -B {params.basename} {params.genome} -1 {input.r1} -2 {input.r2} 2> {log}"

rule merge_convert:
	input:
		get_bam_pe
	output:
		"results/merging/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_merged.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/merging/{sample}{techrep}-{biorep}/bam_to_sam.log"
	params:
		extra=""
	threads:
		1
	shell:
		"samtools merge {output} {input} -O sam {params.extra} -@ {threads} &> {log}"

rule sort:
	input:
		rules.merge_convert.output
	output:
		"results/sorted/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_alignment_sorted.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/sorted/{sample}{techrep}-{biorep}/sort_by_name.log"
	params:
		extra=""
	threads:
		1
	shell:
		"samtools sort -n  -o {output} {input}  {params.extra} -@ {threads}  &> {log}"

rule deduplicate:
	input:
		rules.sort.output
	output:
		"results/deduplicate/{sample}{techrep}-{biorep}/{sample}{techrep}-{biorep}_merged.deduplicated.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/deduplicate/{sample}{techrep}-{biorep}/deduplicate.log"
	params:
		basename="{sample}{techrep}-{biorep}_merged", #not compatible with multiple mode
		outdir="results/deduplicate/{sample}{techrep}-{biorep}/",
		extra="" 
	threads:
		1
	shell:
		"deduplicate_bismark -p {input} -o {params.basename} --output_dir {params.outdir} --sam 2> {log}"
