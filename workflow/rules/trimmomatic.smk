rule trimmomatic_pe:
	input:
		unpack(get_raw)
	output:
		r1=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-1.fq"),
		r1_unpaired=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-1.unpaired.fq"),
		r2=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-2.fq"),
		r2_unpaired=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-2.unpaired.fq"),
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
		config['params']['trimmomatic-pe']['threads']
	shell:
		"trimmomatic PE -phred33 -threads {threads} -trimlog {log}"
		" {input} "
		" {output} "
		" {params.trimmer}:{params.adapters}:{params.trimmeropts} {params.extra} 2> {log}"

