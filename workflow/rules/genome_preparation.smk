rule genome_preparation:
	output:
		get_abs(config['resources']['ref']['genome']) + "/genomic_nucleotide_frequencies.txt"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/common/genome_preparation.log"
	params:
		# list of trimmers (see manual)
		genome=get_abs(config['resources']['ref']['genome']),
		aligner=config["params"]["bismark"]["aligner"],
		# optional parameters
		extra=config["params"]["genome_preparation"]["extra"]
	benchmark:
		repeat("benchmarks/common/genome_preparation.tsv",benchmark)
	threads:
		config['params']['genome_preparation']['threads']
	shell:
		"bismark_genome_preparation  {params.genome} --{params.aligner} --parallel {threads} --genomic_composition {params.extra} 2> {log} "

