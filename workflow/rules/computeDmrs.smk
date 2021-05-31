	
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
	resources:
		cpus=8,
		mem_mb= lambda  Input : int(genomeSize*11*8*len(Input)),
		time_min=1440
	script:
		"../scripts/compute.R"
