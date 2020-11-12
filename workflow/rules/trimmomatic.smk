rule trimmomatic_pe:
	input:
		unpack(get_raw)
	output:
		r1="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-1.fq.gz",
		r1_unpaired="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-1.unpaired.fq.gz",
		r2="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-2.fq.gz",
		r2_unpaired="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-2.unpaired.fq.gz",
	conda:
		"../envs/trimmomatic.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-trimmomatic.log"
	params:
		# list of trimmers (see manual)
		trimmer=config["params"]["trimmomatic-pe"]["trimmer"],
		trimmeropts=config["params"]["trimmomatic-pe"]["trimmer-options"],
		adapters=config["resources"]["adapters"],
		# optional parameters
		extra="",
	benchmark:
		repeat("benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-trimmomatic.tsv",benchmark)
	threads:
		2
	shell:
		"trimmomatic PE -phred33 -threads {threads} -trimlog {log}"
		" {input} "
		" {output} "
		" {params.trimmer}:{params.adapters}:{params.trimmeropts} {params.extra} 2> {log}"

