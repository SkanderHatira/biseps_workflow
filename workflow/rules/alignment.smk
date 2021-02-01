rule alignment_bismark_pe:
	input:
		rules.genome_preparation.output,
		unpack(get_data)
	output:
		bam=temp(outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.bam'),
		report=temp(outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_PE_report.txt'),
		nucl=temp(outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.nucleotide_stats.txt'),
		tempdir=temp(directory(outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-tmp/')),
	conda:
		"../envs/bismark.yaml"
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-alignment_bismark_pe.log"
	params:
		#genome_directory
		genome= get_abs(config['resources']['ref']['genome']),
		# alignments parameters
		score_min = lambda wildcards : config[wildcards.sample]["params"]["bismark"]["score_min"],
		N= lambda wildcards : config[wildcards.sample]["params"]["bismark"]["N"],
		L= lambda wildcards : config[wildcards.sample]["params"]["bismark"]["L"], 
		aligner= lambda wildcards : config[wildcards.sample]["params"]["bismark"]["aligner"],
		outdir= outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/',
		# aligners parameters (see manual) either bowtie2 or hisat2 specific option
		aligner_options= lambda wildcards : config[wildcards.sample]['params']['bismark']['aligner_options'],
		# optional parameters
		instances= lambda wildcards : config[wildcards.sample]['params']['bismark']['instances'],
		flags= lambda wildcards : unpack_boolean_flags(config[wildcards.sample]['params']['bismark']['bool_flags']),
		extra= lambda wildcards : config[wildcards.sample]['params']['bismark']['extra']
	resources:
		cpus=lambda wildcards : 5*config[wildcards.sample]['params']['bismark']['instances'],
		mem_mb=30000,
		time_min=1440
	benchmark:
		repeat(outdir+"benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-alignment_bismark_pe.tsv",benchmark)
	shell:
		"bismark --score_min {params.score_min} -N {params.N} -L {params.L} --{params.aligner}  --bam {params.aligner_options} {params.flags} {params.extra} "
		"--temp_dir {output.tempdir}  -o {params.outdir} --parallel {params.instances} {params.genome} -1 {input.r1} -2 {input.r2} 2> {log}; "

rule override_bismark_naming:
	input:
		bam=outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.bam',
		report=outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_PE_report.txt',
		nucl=outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.nucleotide_stats.txt',		
	output:
		bam=temp(outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_pe.bam'),
		report=outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_PE_report.txt',
		nucl=outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_pe.nucleotide_stats.txt',
	shell:
		"mv {input.bam} {output.bam}; "
		"mv {input.report} {output.report}; "
		"mv {input.nucl} {output.nucl}; "
rule convert:
	input:
		get_bam_pe
	output:
		temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.sam")
	conda:
		"../envs/bismark.yaml"
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-convert.log"
	benchmark:
		repeat(outdir+"benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-convert.tsv",benchmark)
	shell:
		"samtools view -h -@ {resources.cpus} -o {output} {input}  2> {log}"

rule deduplicate:
	input:
		rules.convert.output
	output:
		temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.deduplicated.sam"),
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.deduplication_report.txt"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-deduplicate.log"
	params:
		basename="{sample}",
		outdir=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark",
		extra= lambda wildcards : config[wildcards.sample]['params']['deduplicate']['extra'] 
	benchmark:
		repeat(outdir+"benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-deduplicate.tsv",benchmark)
	shell:
		"deduplicate_bismark -p {input} -o {params.basename} --output_dir {params.outdir} --sam 2> {log};"
