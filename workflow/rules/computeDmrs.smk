from snakemake.utils import validate
import pandas as pd

validate(config, schema="../schemas/comparison.config.schema.yaml")

comparisons = pd.read_csv(config["comparisons"], dtype=str, sep="\t").set_index(["id",], drop=False)
print(comparisons)
# comparisons.index.names = ["comp_id"]
# comparisons.index = comparisons.index.set_levels(
# 	[i.astype(str) for i in comparisons.index.levels])  # enforce str in index
outdir = config['general']['outdir']
wildcard_constraints:
	id="|".join(comparisons["id"]),
	
	
def get_CX_reports(wildcards):
	u = comparisons.loc[ wildcards.id, ["control", "treatment"] ].dropna()
	print(u.control)
	print(u.treatment)
	return { 'control' : u.control.split(",") , 'treatment' : u.treatment.split(",") }
print(comparisons)
rule compute:
	input:
		unpack(get_CX_reports)
	output:
		output="results/comparisons/{id}/{id}.bed"
	log:
		"results/comparisons/{id}/{id}_log.out"
	conda:
		"../envs/dmrcaller.yaml"
	threads: 4
	script:
		"../scripts/compute.R"
