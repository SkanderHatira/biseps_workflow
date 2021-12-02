	
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
		methylDB=directory(outdir+"methylation/methylDB-{id}-{context}/"),
		methylationStatsTxt=outdir+"methylation/{id}-{context}/{id}-{context}-methylation-stats.txt",
		methylationStatsPdf=outdir+"methylation/{id}-{context}/{id}-{context}-methylation-stats.pdf",
		coverageStatsTxt=outdir+"methylation/{id}-{context}/{id}-{context}-coverage-stats.txt",
		coverageStatsPdf=outdir+"methylation/{id}-{context}/{id}-{context}-coverage-stats.pdf",
		correlationTxt=outdir+"methylation/{id}-{context}/{id}-{context}-correlation-stats.txt",
		correlationPdf=outdir+"methylation/{id}-{context}/{id}-{context}-correlation-stats.pdf",
		clustersPdf=outdir+"methylation/{id}-{context}/{id}-{context}-clusters.pdf",
		pcaScreePdf=outdir+"methylation/{id}-{context}/{id}-{context}-PCA-screeplot.pdf",
		pcaPdf=outdir+"methylation/{id}-{context}/{id}-{context}-PCA.pdf",
		hyperMethylation=outdir+"methylation/{id}-{context}/{id}-{context}-HyperMethylated-stats.txt",
		hypoMethylation=outdir+"methylation/{id}-{context}/{id}-{context}-HypoMethylated-stats.txt",
		overAllMethylation=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation-stats.txt",
		hyperMethylationBed=outdir+"methylation/{id}-{context}/{id}-{context}-HyperMethylated.bed",
		hypoMethylationBed=outdir+"methylation/{id}-{context}/{id}-{context}-HypoMethylated.bed",
		overAllMethylationBed=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation.bed",
	log:
		outdir+"methylation/{id}-{context}/{id}-{context}-log.out"
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
rule closest_feature:
	input:
		bed=rules.compute_methylkit.output["overAllMethylationBed"],
	output:
		outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation-closest.bed"
		# outdir+"results/{id}/{id}_log-{context}.out.closest.bed",
	conda:
		"../envs/tabix.yaml" if config["platform"] == 'linux' else ''
	log:
		outdir+"methylation/{id}-{context}/{id}-{context}.closest.log"
	params:
		annot=config['resources']['annot']
	shell:
		"bedtools closest -a {input.bed} -b {params.annot} -D b > {output}"
rule indexBed:
	input:
		rules.compute_methylkit.output["overAllMethylationBed"],
	output:
		outbg=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation.bed.gz",
		outbi=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation.bed.gz.tbi"
		# outbg=outdir+"results/{id}/{id}-{context}.bed.gz",
		# outbi=outdir+"results/{id}/{id}-{context}.bed.gz.tbi",
	conda:
		"../envs/tabix.yaml" if config["platform"] == 'linux' else ''
	log:
		outdir+"methylation/{id}-{context}/{id}-{context}.indexBed.log"
	shell:
		"bgzip  {input} -c > {output.outbg}; "
		"tabix {output.outbg}"
rule indexClosest:
	input:
		rules.closest_feature.output[0],
	output:
		outbg=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation-closest.bed.gz",
		outbi=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation-closest.bed.gz.tbi"
	conda:
		"../envs/tabix.yaml" if config["platform"] == 'linux' else ''
	log:
		outdir+"methylation/{id}-{context}/{id}-{context}.indexClosest.log"
	shell:
		"bgzip {input} -c > {output.outbg}; "
		"tabix {output.outbg}"
