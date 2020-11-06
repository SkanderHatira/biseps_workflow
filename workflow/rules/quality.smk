rule fastqc:
	input:
		unpack(get_data)
	output:
		directory("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/quality/{sample}-L_{lane}/")
	conda:
		"../envs/quality.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-L_{lane}-fastqc.log"
	params:
		# optional parameters
		extra="",
	threads:
		1
	shell:
		"fastqc {input} -o {output} {params.extra} 2> {log}"


rule multiqc:
	input:
		fqc=lambda wildcards : expand("results/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}/quality/{{sample}}-L_{lane}/",lane=get_lanes(wildcards)),
		report="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-sorted.deduplicated.CX_report.txt"
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/multiqc_report.html"
	conda:
		"../envs/quality.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-multiqc.log"
	params:
		aligndir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/",
		extractdir="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		# optional parameters
		extra="",
	threads:
		1
	shell:
		"multiqc {input.fqc} {params.aligndir} {params.extractdir}-n {output} 2> {log}"
