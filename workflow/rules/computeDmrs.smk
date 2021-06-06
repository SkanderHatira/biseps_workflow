	
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
		CG="results/comparisons/{id}/{id}-CG.bed",
		CHG="results/comparisons/{id}/{id}-CHG.bed",
		CHH="results/comparisons/{id}/{id}-CHH.bed",
	log:
		"results/comparisons/{id}/{id}_log.out"
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
		cpus=1,
		mem_mb= lambda  Input : int(genomeSize*11*8*len(Input)),
		time_min=8440
	script:
		"../scripts/compute.R"
