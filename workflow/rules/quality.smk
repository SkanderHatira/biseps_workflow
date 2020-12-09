rule fastqc:
	input:
		unpack(get_data)
	output:
		directory("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/quality/")
	conda:
		"../envs/quality.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/fastqc.log"
	params:
		# optional parameters
		extra=  config['params']['fastqc']['extra'],
	threads:
		1
	shell:
		"mkdir -p {output} ; "
		"fastqc {input} -o {output} {params.extra} 2> {log}"

rule multiqc:
	input:
		fqc=rules.fastqc.output,
		report="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.CX_report.txt",
	output:
		file="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/multiqc_report.html",
		data=directory("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/multiqc_report_data")
	conda:
		"../envs/quality.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-multiqc.log"
	params:
		aligndir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/",
		methdir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		# optional parameters
		extra=config['params']['multiqc']['extra'],
	threads:
		1
	shell:
		"multiqc {input.fqc} {params.aligndir} {params.methdir} -n {output.file} 2> {log}"

rule bismark_html_report:
	input:
		align="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_PE_report.txt",
		nucl="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_pe.nucleotide_stats.txt",
		dedup="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.deduplication_report.txt",
		split='results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated_splitting_report.txt',
		mbias="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.M-bias.txt"
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-bismark_report.html"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-bismark_report.log"
	params:
		outdir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/",
		aligndir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/",
		methdir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		filename="{sample}-bismark_report.html",
		# optional parameters
		extra="",
	threads:
		1
	shell:
		"bismark2report --alignment_report {input.align} "
		"--dedup_report {input.dedup} "
		"--nucleotide_report {input.nucl} "
		"--splitting_report {input.split} "
		"--mbias_report {input.mbias} --dir {params.outdir} -o {params.filename} 2> {log}"	