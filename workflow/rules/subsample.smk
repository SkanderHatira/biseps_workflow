rule seqtk:
	input:
		get_fastqs
	output:
		"results/sub/{sample}{lane}{techrep}-{biorep}-{side}.fq"
	conda:
		"../envs/seqtk.yaml"
	log:
		"logs/seqtk/{sample}{lane}{techrep}-{biorep}-{side}.log"
	params:
		# Random seed
		seed=config["params"]["seqtk"]["seed"],
		# optional parameters
		extra="",
	threads:
		2
	shell:
		"seqtk sample -s {params.seed} {input} 10000 > {output}"

