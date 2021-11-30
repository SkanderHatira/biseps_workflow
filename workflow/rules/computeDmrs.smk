	
def get_CX_reports(wildcards):
	u = comparisons.loc[ wildcards.id, ["control", "treatment"] ].dropna()
	return { 'control' : u.control.split(",") , 'treatment' : u.treatment.split(",") }
def get_id():
	return comparisons["id"].unique()

genomeSize= os.path.getsize(config['resources']['ref']['genome'])/(1024*1024)

rule compute_methylkit:
	input:
		unpack(get_CX_reports),
		named=config['resources']['ref']['genome']
	output:
		methylDB=directory(outdir+"methylkit_results/methylDB-{id}-{context}/"),
		methylationStatsTxt=outdir+"methylkit_results/{id}-{context}/{id}-{context}-methylation-stats.txt",
		methylationStatsPdf=outdir+"methylkit_results/{id}-{context}/{id}-{context}-methylation-stats.pdf",
		coverageStatsTxt=outdir+"methylkit_results/{id}-{context}/{id}-{context}-coverage-stats.txt",
		coverageStatsPdf=outdir+"methylkit_results/{id}-{context}/{id}-{context}-coverage-stats.pdf",
		correlationTxt=outdir+"methylkit_results/{id}-{context}/{id}-{context}-correlation-stats.txt",
		correlationPdf=outdir+"methylkit_results/{id}-{context}/{id}-{context}-correlation-stats.pdf",
		clustersPdf=outdir+"methylkit_results/{id}-{context}/{id}-{context}-clusters.pdf",
		pcaScreePdf=outdir+"methylkit_results/{id}-{context}/{id}-{context}-PCA-screeplot.pdf",
		pcaPdf=outdir+"methylkit_results/{id}-{context}/{id}-{context}-PCA.pdf",

	log:
		outdir+"methylkit_results/{id}-{context}/{id}-{context}-log.out"
	conda:
		"../envs/methylkit.yaml" if config["platform"] == 'linux' else ''
	params:
		bins = config["params"]["bins"],
		outdir = config["general"]["outdir"],
		windowSize=  config["params"]["windowSize"],
		stepSize = config["params"]["stepSize"],
		test=  config["params"]["test"],
		qValue= config["params"]["qValue"],
		minCov=config["params"]["minCov"],
		minDiff=  config["params"]["minDiff"],
	resources:
		cpus=4
	script:
		"../scripts/methylkit.R"
# rule closest_feature:
# 	input:
# 		bed=rules.compute.output[0],
# 	output:
# 		outdir+"results/{id}/{id}_log-{context}.out.closest.bed",
# 	conda:
# 		"../envs/tabix.yaml" if config["platform"] == 'linux' else ''
# 	log:
# 		outdir+"results/{id}/{id}_log-{context}.closest.out"
# 	params:
# 		annot=config['resources']['annot']
# 	shell:
# 		"bedtools closest -a {input.bed} -b {params.annot} -D b > {output}"
# rule indexBed:
# 	input:
# 		rules.compute.output[0],
# 	output:
# 		outbg=outdir+"results/{id}/{id}-{context}.bed.gz",
# 		outbi=outdir+"results/{id}/{id}-{context}.bed.gz.tbi",
# 	conda:
# 		"../envs/tabix.yaml" if config["platform"] == 'linux' else ''
# 	log:
# 		outdir+"results/{id}/{id}_log-{context}.indexBed.out"

# 	shell:
# 		"bgzip  {input} -c > {output.outbg}; "
# 		"tabix {output.outbg}"
# rule indexClosest:
# 	input:
# 		rules.closest_feature.output[0],
# 	output:
# 		outbg=outdir+"results/{id}/{id}_log-{context}.out.closest.bed.gz",
# 		outbi=outdir+"results/{id}/{id}_log-{context}.out.closest.bed.gz.tbi",
# 	conda:
# 		"../envs/tabix.yaml" if config["platform"] == 'linux' else ''
# 	log:
# 		outdir+"results/{id}/{id}_log-{context}.indexClosest.out"
# 	shell:
# 		"bgzip {input} -c > {output.outbg}; "
# 		"tabix {output.outbg}"


# rule compute:
# 	input:
# 		unpack(get_CX_reports),
# 		named=config['resources']['ref']['genome']
# 	output:
# 		bed=outdir+"results/{id}/{id}-{context}.bed",
# 	log:
# 		outdir+"results/{id}/{id}_log-{context}.out"
# 	conda:
# 		"../envs/methylkit.yaml" if config["platform"] == 'linux' else ''
# 	params:
# 		method= config["params"]["method"],
# 		binSize=  config["params"]["binSize"],
# 		kernelFunction = config["params"]["kernelFunction"],
# 		test=  config["params"]["test"],
# 		pseudocountM=  config["params"]["pseudocountM"],
# 		pseudocountN= config["params"]["pseudocountN"],
# 		pValueThreshold= config["params"]["pValueThreshold"],
# 		minCytosinesCount=config["params"]["minCytosinesCount"],
# 		minProportionDifference=  config["params"]["minProportionDifference"],
# 		minGap= config["params"]["minGap"],
# 		minSize= config["params"]["minSize"],
# 		minReadsPerCytosine=config["params"]["minReadsPerCytosine"],
# 		cores=config["params"]["cores"]
# 	resources:
# 		cpus=10,
# 		mem_mb= lambda  Input : int(genomeSize*11*15*len(Input)),
# 	script:
# 		"../scripts/methylkit.R"
