rule alignment_bismark_pe:
	input:
		rules.genome_preparation.output,
		unpack(get_data)
	output:
		bam='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-L_{lane}-1_bismark_bt2_pe.bam',
		tempdir=temp(directory('results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-L_{lane}-temp/')),
	
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-L_{lane}-alignment_bismark_pe.log"
	params:
		#genome_directory
		genome= config['resources']['ref']['genome_directory'],
		# bismark parameters
		bismark= "-N 1 -L 20 -score_min L,0,-0.6",
		aligner= config["params"]["bismark"]["aligner"],
		outdir= 'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/',
		# aligners parameters (see manual)
		aligner_options= "",
		# optional parameters
		instances= config['params']['bismark']['instances'],
		extra=""
	threads:
		3*config['params']['bismark']['instances']
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-L_{lane}-alignment_bismark_pe.tsv",benchmark)
	shell:
		"bismark --{params.aligner} {params.bismark}  --bam {params.aligner_options} {params.extra}"
		"--temp_dir {output.tempdir}  -o {params.outdir} --parallel {params.instances} {params.genome} -1 {input.r1} -2 {input.r2} 2> {log}"

rule alignment_bsmap_pe:
	input:
		rules.genome_preparation.output,
		unpack(get_data)
	output:
		'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bsmap/{sample}-L_{lane}-bsmap_pe.bsp'
	conda:
		"../envs/bsmap.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-L_{lane}-alignment_bsmap_pe.log"
	params:
		#genome_directory
		genome= config['params']['bsmap']['genome'],
		extra=""
	threads:
		2
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-L_{lane}-alignment_bsmap_pe.tsv",benchmark)
	shell:
		"bsmap -a {input.r1} -b {input.r2} -d {params.genome} "
		"-o {output} -p 8 -w 100 -v 5 2> {log}"

rule merge_convert:
	input:
		get_bam_bismark_pe
	output:
		temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-merged.sam")
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-merge_convert.log"
	params:
		extra=""
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-merge_convert.tsv",benchmark)
	threads:
		1
	shell:
		"samtools merge {output} {input} -f -O sam {params.extra} -@ {threads} &> {log}"

rule sort:
	input:
		rules.merge_convert.output
	output:
		temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-sorted.sam")
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-sort.log"
	params:
		extra=""
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-sort.tsv",benchmark)
	threads:
		1
	shell:
		"samtools sort -n  -o {output} {input}  {params.extra} -@ {threads}  &> {log}"

rule deduplicate:
	input:
		rules.sort.output
	output:
		temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.deduplicated.sam")
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-deduplicate.log"
	params:
		basename="{sample}",
		outdir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark",
		extra="" 
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-deduplicate.tsv",benchmark)
	threads:
		1
	shell:
		"deduplicate_bismark -p {input} -o {params.basename} --output_dir {params.outdir} --sam 2> {log}"
