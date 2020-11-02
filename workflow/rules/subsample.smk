rule seqtk_pe:
	input:
		unpack(get_fastqs)
	output:
		r1="results/sub/{sample}{lane}{techrep}-{biorep}-1.fq",
		r2="results/sub/{sample}{lane}{techrep}-{biorep}-2.fq"
	conda:
		"../envs/seqtk.yaml"
	log:
		"logs/seqtk/{sample}{lane}{techrep}-{biorep}.log"
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
