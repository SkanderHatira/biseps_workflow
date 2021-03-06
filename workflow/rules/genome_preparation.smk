rule genome_preparation:
	input:	config['resources']['ref']['genome']
	output:
		directory(get_abs(config['resources']['ref']['genome']) + "/Bisulfite_Genome"),
		config['resources']['ref']['genome'] + ".fai"
	conda:
		"../envs/bismark.yaml" if config["platform"] == 'linux' else ''
	log:
		outdir+"logs/common/genome_preparation.log"
	params:
		# list of trimmers (see manual)
		genome=get_abs(config['resources']['ref']['genome']),
		genome_file=config['resources']['ref']['genome'],
		aligner= config["general"]["genome_preparation"]["aligner"],
		# optional parameters
		extra= config["general"]["genome_preparation"]["extra"]
	benchmark:
		repeat(outdir+"benchmarks/common/genome_preparation.tsv",benchmark)
	resources:
		cpus=config['general']['genome_preparation']['threads'],
		mem_mb=30000,
		time_min=5440
	shell:
		"bash workflow/scripts/parallel_commands.sh \'bismark_genome_preparation  {params.genome} --{params.aligner} --parallel {resources.cpus} --genomic_composition {params.extra}\' \'samtools faidx {params.genome_file} \' 2> {log} "

