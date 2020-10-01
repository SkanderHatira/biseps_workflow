rule fastqc:
	input:
		unpack(get_trimmed)
	output:
		directory("results/quality/fastqc/{sample}{lane}{techrep}-{biorep}/")
	conda:
		"../envs/quality.yaml"
	log:
		"logs/fastqc/{sample}{lane}{techrep}-{biorep}.log"
	params:
		# optional parameters
		extra="",
	threads:
		2
	shell:
		"fastqc {input} -o {output} {params.extra} 2> {log}"


rule multiqc:
	input:
		rules.fastqc.output
	output:
		"results/quality/multiqc/{sample}{lane}{techrep}-{biorep}/multiqc_report.html"
	conda:
		"../envs/quality.yaml"
	log:
		"logs/multiqc/{sample}{lane}{techrep}-{biorep}.log"
	params:
		# optional parameters
		extra="",
	threads:
		2
	shell:
		"multiqc {input} -n {output} 2> {log}"
