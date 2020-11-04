rule subsampling:
	input:
		unpack(get_fastqs)
	output:
		r1="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-L_{lane}-1.fq",
		r2="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-L_{lane}-2.fq"
	conda:
		"../envs/seqtk.yaml"
	log:
		"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-L_{lane}-subsampling.log"
	params:
		# Random seed
		seed=config["params"]["seqtk"]["seed"],
		size=config["params"]["seqtk"]["size"],
		# optional parameters
		extra="",
	threads:
		1
	shell:
		"seqtk sample -s {params.seed} {input.r1} {params.size} > {output.r1} 2>> {log} ;"
		"seqtk sample -s {params.seed} {input.r2} {params.size} > {output.r2} 2>> {log}  "
