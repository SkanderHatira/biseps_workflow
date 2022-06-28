	
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
		methylationStatsPdf=report(outdir+"methylation/{id}-{context}/{id}-{context}-methylation-stats.pdf",category="stats"),
		coverageStatsTxt=outdir+"methylation/{id}-{context}/{id}-{context}-coverage-stats.txt",
		coverageStatsPdf=report(outdir+"methylation/{id}-{context}/{id}-{context}-coverage-stats.pdf",category="stats"),
		correlationTxt=outdir+"methylation/{id}-{context}/{id}-{context}-correlation-stats.txt",
		correlationPdf=report(outdir+"methylation/{id}-{context}/{id}-{context}-correlation-stats.pdf",category="stats"),
		clustersPdf=report(outdir+"methylation/{id}-{context}/{id}-{context}-clusters.pdf",category="clusters"),
		pcaScreePdf=report(outdir+"methylation/{id}-{context}/{id}-{context}-PCA-screeplot.pdf",category="stats",subcategory="pca"),
		pcaPdf=report(outdir+"methylation/{id}-{context}/{id}-{context}-PCA.pdf",category="stats",subcategory="pca"),
		overAllMethylation=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation-stats.txt",
		overAllMethylationBed=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation.bed",
	log:
		outdir+"methylation/{id}-{context}/{id}-{context}-log.out"
	conda:
		"../envs/methylkit.yaml" if config["platform"] == 'linux' else ''
	params:
		method = config["params"]["method"],
		outdir = config["general"]["outdir"],
		windowSize=  config["params"]["windowSize"],
		stepSize = config["params"]["stepSize"],
		test=  config["params"]["test"],
		qValue= config["params"]["qValue"],
		minCov=config["params"]["minCov"],
		minDiff=  config["params"]["minDiff"],
	resources:
		cpus=4,
		mem_mb= lambda  Input : int(genomeSize*11*len(Input)*5),
	script:
		"../scripts/methylkit.R"
rule closest_feature:
	input:
		annot=config['resources']['annot'],
		bed=rules.compute_methylkit.output["overAllMethylationBed"]
	output:
		closest=outdir+"methylation/{id}-{context}/{id}-{context}-overallMethylation-closest.bed",
		# outdir+"results/{id}/{id}_log-{context}.out.closest.bed",
	conda:
		"../envs/tabix.yaml" if config["platform"] == 'linux' else ''
	log:
		outdir+"methylation/{id}-{context}/{id}-{context}.closest.log"
	params:
		sorted=config['resources']['annot']+".tmp",
	shell:
		"bedtools sort -i {input.annot} > {params.sorted}  ;"
		"bedtools closest -a {input.bed} -b {input.annot} -D b > {output.closest}"
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
	resources:
		cpus=4,
		mem_mb= 30000
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
	resources:
		cpus=4,
		mem_mb= 30000
	shell:
		"bgzip {input} -c > {output.outbg}; "
		"tabix {output.outbg}"
