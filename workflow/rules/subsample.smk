rule entrypoint:
	input:
		unpack(get_fastqs)
	output:
		r1=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-1.fq"),
		r2=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-2.fq")
	run:
		if os.path.splitext(input.r1)[1] == '.gz':
			shell("gunzip -c {input.r1} > {output.r1}; ")
		else:
			shell("ln -sr {input.r1} {output.r1}; ")
		if os.path.splitext(input.r2)[1] == '.gz':
			shell("gunzip -c {input.r2} > {output.r2}; ")
		else:
			shell("ln -sr {input.r2} {output.r2}; ")

rule merge_lanes_pe:
	input:
		r1= lambda wildcards : expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-1.fq",lane=get_lanes(wildcards),**wildcards),
		r2= lambda wildcards : expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/.tmp/{sample}-L_{lane}-2.fq",lane=get_lanes(wildcards),**wildcards)
	output:
		r1=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-1.fq"),
		r2=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-2.fq")
	shell:
		"cat {input.r1} > {output.r1};"
		"cat {input.r2} > {output.r2}"


rule subsampling:
	input:
		r1=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-1.fq",
		r2=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-2.fq"
	output:
		r1=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-1.fq"),
		r2=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-2.fq")
	conda:
		"../envs/seqtk.yaml"
	params:
		# Random seed
		seed= lambda wildcards : config[wildcards.sample]["params"]["seqtk"]["seed"],
		size= lambda wildcards : config[wildcards.sample]["params"]["seqtk"]["size"],
		# optional parameters
		extra="",
	shell:
		"seqtk sample -s {params.seed} {input.r1} {params.size} > {output.r1} ; "
		"seqtk sample -s {params.seed} {input.r2} {params.size} > {output.r2}   "
