rule genome_preparation:
	output:
		get_abs(config['resources']['ref']['genome']) + "/genomic_nucleotide_frequencies.txt"
	conda:
		"../envs/bismark.yaml"
	log:
		outdir+"logs/common/genome_preparation.log"
	params:
		# list of trimmers (see manual)
		genome=get_abs(config['resources']['ref']['genome']),
		aligner= config["general"]["genome_preparation"]["aligner"],
		# optional parameters
		extra= config["general"]["genome_preparation"]["extra"]
	benchmark:
		repeat(outdir+"benchmarks/common/genome_preparation.tsv",benchmark)
	resources:
		cpus=config['general']['genome_preparation']['threads'],
		mem_mb=30000,
		time_min=1440
	shell:
		"bismark_genome_preparation  {params.genome} --{params.aligner} --parallel {resources.cpus} --genomic_composition {params.extra} 2> {log} "

