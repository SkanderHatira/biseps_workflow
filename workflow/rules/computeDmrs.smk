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
	print(u)
	return { 'control' : f"{u.control}", 'treatment' : f"{u.treatment}" }
print(comparisons)
rule compute:
	input:
		control=["chr3test_a_thaliana_met13.CX_report"],
		treatment=["chr3test_a_thaliana_wt.CX_report"]
	output:
		output="results/comparisons/{id}/{id}.bed"
	log:
		"results/comparisons/{id}/{id}_log.out"
	conda:
		"../envs/dmrcaller.yaml"
	script:
		"../scripts/compute.R"
