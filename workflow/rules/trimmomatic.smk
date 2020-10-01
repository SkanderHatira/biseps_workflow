rule trimmomatic_pe:
	input:
		unpack(get_raw)
	output:
		r1="results/trimmed/{sample}{lane}{techrep}-{biorep}-1.fq.gz",
		r2="results/trimmed/{sample}{lane}{techrep}-{biorep}-2.fq.gz",
		# reads where trimming entirely removed the mate
		r1_unpaired="results/trimmed/{sample}{lane}{techrep}-{biorep}-1.unpaired.fq.gz",
		r2_unpaired="results/trimmed/{sample}{lane}{techrep}-{biorep}-2.unpaired.fq.gz"
	conda:
		"../envs/trimmomatic.yaml"
	log:
		"logs/trimmomatic/{sample}{lane}{techrep}-{biorep}.log"
	params:
		# list of trimmers (see manual)
		trimmer=config["params"]["trimmomatic-pe"]["trimmer"],
		# optional parameters
		extra="",
	threads:
		2
	shell:
		"trimmomatic PE -phred33 -threads {threads} -trimlog {log}"
		" {input} "
		" {output} "
		" {params.trimmer} {params.extra} 2> {log}"
