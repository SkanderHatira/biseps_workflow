rule trimmomatic_pe:
	input:
		unpack(get_raw)
	output:
		r1=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-1.fq"),
		r1_unpaired=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-1.unpaired.fq"),
		r2=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-2.fq"),
		r2_unpaired=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-2.unpaired.fq"),
	conda:
		"../envs/trimmomatic.yaml"
	log:
		temp(outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-trimmomatic.log")
	params:
		# list of trimmers (see manual)
		trimmer= lambda wildcards : config[wildcards.sample]["params"]["trimmomatic-pe"]["trimmer"],
		trimmeropts= lambda wildcards : config[wildcards.sample]["params"]["trimmomatic-pe"]["trimmer-options"],
		adapters=config["resources"]["adapters"],
		# optional parameters
		extra="",
	benchmark:
		repeat(outdir+"benchmarks/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-trimmomatic.tsv",benchmark)
	resources:
		cpus=lambda wildcards : config[wildcards.sample]['params']['trimmomatic-pe']['threads'],
		time_min=1440
	shell:
		"trimmomatic PE -phred33 -threads {resources.cpus} -trimlog {log}"
		" {input} "
		" {output} "
		" {params.trimmer}:{params.adapters}:{params.trimmeropts} {params.extra} 2> {log}"

