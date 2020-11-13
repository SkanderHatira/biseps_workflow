rule rename:
	input:
		unpack(get_fastqs)
	output:
		r1=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-1.fq"),
		r2=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-2.fq")
	threads:
		1

	run:
		if os.path.splitext(input.r1) == '.gz':
			shell("gzip -c {input.r1} > {output.r1}; ")
		else:
			shell("ln -sr {input.r1} {output.r1}; ")
		if os.path.splitext(input.r2) == '.gz':
			shell("gzip -c {input.r2} > {output.r2}; ")
		else:
			shell("ln -sr {input.r2} {output.r2}; ")

rule merge_lanes_pe:
	input:
		r1= lambda wildcards : expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-1.fq",lane=get_lanes(wildcards),**wildcards),
		r2= lambda wildcards : expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-2.fq",lane=get_lanes(wildcards),**wildcards)
	output:
		r1=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-1.fq"),
		r2=temp("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-2.fq")
	threads:
		1
	run:
		if len(get_lanes(wildcards)) > 1:
			shell("cat {input.r1} > {output.r1}")
			shell("cat {input.r2} > {output.r2}")
		else:
			shell("ln -sr {input.r1} {output.r1}")
			shell("ln -sr {input.r2} {output.r2}")

rule subsampling:
	input:
		r1="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-1.fq",
		r2="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-2.fq"
	output:
		r1="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-1.fq",
		r2="results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-2.fq"
	conda:
		"../envs/seqtk.yaml"
	params:
		# Random seed
		seed=config["params"]["seqtk"]["seed"],
		size=config["params"]["seqtk"]["size"],
		# optional parameters
		extra="",
	threads:
		1
	shell:
		"seqtk sample -s {params.seed} {input.r1} {params.size} > {output.r1} ; "
		"seqtk sample -s {params.seed} {input.r2} {params.size} > {output.r2}   "
