rule alignment_bismark_pe:
	input:
		rules.genome_preparation.output,
		unpack(get_data)
	output:
		bam=temp('results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.bam'),
		report=temp('results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_PE_report.txt'),
		nucl=temp('results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.nucleotide_stats.txt'),
		tempdir=temp(directory('results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-tmp/')),
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-alignment_bismark_pe.log"
	params:
		#genome_directory
		genome= get_abs(config['resources']['ref']['genome']),
		# bismark parameters
		bismark=  "",#-N 1 -L 20 -score_min L,0,-0.6" default aligmnment params (irrespective of alignment tool)
		aligner= config["params"]["bismark"]["aligner"],
		outdir= 'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/',
		# aligners parameters (see manual) either bowtie2 or hisat2 specific option
		aligner_options= "",
		# optional parameters
		instances= config['params']['bismark']['instances'],
		extra="--nucleotide_coverage",
	threads:
		3*config['params']['bismark']['instances']
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-alignment_bismark_pe.tsv",benchmark)
	shell:
		"bismark --{params.aligner} {params.bismark}  --bam {params.aligner_options} {params.extra} "
		"--temp_dir {output.tempdir}  -o {params.outdir} --parallel {params.instances} {params.genome} -1 {input.r1} -2 {input.r2} 2> {log}; "

rule override_bismark_naming:
	input:
		bam='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.bam',
		report='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_PE_report.txt',
		nucl='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-1_bismark_bt2_pe.nucleotide_stats.txt',		
	output:
		bam='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_pe.bam',
		report='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_PE_report.txt',
		nucl='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_pe.nucleotide_stats.txt',
	threads:
		1
	shell:
		"mv {input.bam} {output.bam}; "
		"mv {input.report} {output.report}; "
		"mv {input.nucl} {output.nucl}; "
rule convert:
	input:
		get_bam_pe
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.sam"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-convert.log"
	params:
		extra=""
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-convert.tsv",benchmark)
	threads:
		1
	shell:
		"samtools view -h -@ {threads} {params.extra} -o {output} {input}  2> {log}"

rule deduplicate:
	input:
		rules.convert.output
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.deduplicated.sam",
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.deduplication_report.txt"
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
		"deduplicate_bismark -p {input} -o {params.basename} --output_dir {params.outdir} --sam 2> {log};"
