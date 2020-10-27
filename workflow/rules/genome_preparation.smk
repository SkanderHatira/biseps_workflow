rule genome_preparation:
	output:
		config['resources']['ref']['genome_directory'] + "/genomic_nucleotide_frequencies.txt"
	conda:
		"../envs/bismark.yaml"
	log:
		"logs/genome_preparation.log"
	params:
		# list of trimmers (see manual)
		genome=config['resources']['ref']['genome_directory'],
		aligner=config["params"]["bismark"]["aligner"],
		# optional parameters
		extra="",
	threads:
		2
	shell:
		"bismark_genome_preparation  {params.genome} --{params.aligner} --parallel {threads} --genomic_composition 2> {log} "

