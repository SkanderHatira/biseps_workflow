rule seqtk:
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
		# optional parameters
		extra="",
	threads:
		2
	shell:
		"seqtk sample -s {params.seed} {input.r1} 10000 > {output.r1}"
		"seqtk sample -s {params.seed} {input.r2} 10000 > {output.r2}"

