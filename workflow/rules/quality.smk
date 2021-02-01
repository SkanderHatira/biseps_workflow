rule fastqc:
	input:
		unpack(get_data)
	output:
		directory(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/quality/")
	conda:
		"../envs/quality.yaml"
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/fastqc.log"
	params:
		# optional parameters
		extra=  lambda wildcards : config[wildcards.sample]['params']['fastqc']['extra'],
	shell:
		"mkdir -p {output} ; "
		"fastqc {input} -o {output} {params.extra} 2> {log}"

rule multiqc:
	input:
		fqc=rules.fastqc.output,
		report=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.CX_report.txt",
	output:
		file=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/multiqc_report.html",
		data=directory(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/multiqc_report_data")
	conda:
		"../envs/quality.yaml"
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-multiqc.log"
	params:
		aligndir=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/",
		methdir=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		# optional parameters
		extra=lambda wildcards : config[wildcards.sample]['params']['multiqc']['extra'],
	shell:
		"multiqc {input.fqc} {params.aligndir} {params.methdir} -n {output.file} 2> {log}"

rule bismark_html_report:
	input:
		align=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_PE_report.txt",
		nucl=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_pe.nucleotide_stats.txt",
		dedup=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}.deduplication_report.txt",
		split=outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated_splitting_report.txt',
		mbias=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.M-bias.txt"
	output:
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-bismark_report.html"
	conda:
		"../envs/bismark.yaml"
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-bismark_report.log"
	params:
		outdir=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/",
		aligndir=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/",
		methdir=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		filename="{sample}-bismark_report.html",
		# optional parameters
		extra="",
	shell:
		"bismark2report --alignment_report {input.align} "
		"--dedup_report {input.dedup} "
		"--nucleotide_report {input.nucl} "
		"--splitting_report {input.split} "
		"--mbias_report {input.mbias} --dir {params.outdir} -o {params.filename} 2> {log}"	
