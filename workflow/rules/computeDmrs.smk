	
def get_CX_reports(wildcards):
	u = comparisons.loc[ wildcards.id, ["control", "treatment"] ].dropna()
	return { 'control' : u.control.split(",") , 'treatment' : u.treatment.split(",") }
def get_id():
	return comparisons["id"].unique()
genomeSize= os.path.getsize(config['resources']['ref']['genome'])/(1024*1024)

rule compute:
	input:
		unpack(get_CX_reports)
	output:
		bed=outdir+"{id}/{id}-{context}.bed",
	log:
		outdir+"{id}/{id}_log-{context}.out"
	conda:
		"../envs/dmrcaller.yaml"
	params:
		method= config["params"]["method"],
		binSize=  config["params"]["binSize"],
		kernelFunction = config["params"]["kernelFunction"],
		test=  config["params"]["test"],
		pseudocountM=  config["params"]["pseudocountM"],
		pseudocountN= config["params"]["pseudocountN"],
		pValueThreshold= config["params"]["pValueThreshold"],
		minCytosinesCount=config["params"]["minCytosinesCount"],
		minProportionDifference=  config["params"]["minProportionDifference"],
		minGap= config["params"]["minGap"],
		minSize= config["params"]["minSize"],
		minReadsPerCytosine=config["params"]["minReadsPerCytosine"],
		cores=config["params"]["cores"]
	resources:
		cpus=10,
		mem_mb= lambda  Input : int(genomeSize*11*8*len(Input)),
	script:
		"../scripts/compute.R"
rule closest_feature:
	input:
		bed=rules.compute.output[0],
	output:
		outdir+"{id}/{id}_log-{context}.out.closest.bed",
	conda:
		"../envs/tabix.yaml"
	log:
		outdir+"{id}/{id}_log-{context}.closest.out"
	params:
		annot=config['resources']['annot']
	shell:
		"bedtools closest -a {input.bed} -b {params.annot} -D b > {output}"
rule indexBed:
	input:
		rules.compute.output[0],
	output:
		outbg=outdir+"{id}/{id}-{context}.bed.gz",
		outbi=outdir+"{id}/{id}-{context}.bed.gz.tbi",
	conda:
		"../envs/tabix.yaml"
	log:
		outdir+"{id}/{id}_log-{context}.indexBed.out"

	shell:
		"bgzip  {input} -c > {output.outbg}; "
		"tabix {output.outbg}"
rule indexClosest:
	input:
		rules.closest_feature.output[0],
	output:
		outbg=outdir+"{id}/{id}_log-{context}.out.closest.bed.gz",
		outbi=outdir+"{id}/{id}_log-{context}.out.closest.bed.gz.tbi",
	conda:
		"../envs/tabix.yaml"
	log:
		outdir+"{id}/{id}_log-{context}.indexClosest.out"
	shell:
		"bgzip {input} -c > {output.outbg}; "
		"tabix {output.outbg}"
