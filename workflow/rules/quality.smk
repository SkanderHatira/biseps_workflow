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
		lambda wildcards : expand("results/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}/quality/{{sample}}-L_{lane}/",lane=get_lanes(wildcards))
	output:
		"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/multiqc_report.html"
	conda:
		"../envs/quality.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-multiqc.log"
	params:
		# optional parameters
		extra="",
	threads:
		1
	shell:
		"multiqc {input} -n {output} 2> {log}"
