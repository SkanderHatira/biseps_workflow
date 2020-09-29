from snakemake.utils import validate
import pandas as pd


# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####

configfile: "config/config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
samples.index.names = ["sample_id"]
validate(samples, schema="../schemas/samples.schema.yaml")

units = pd.read_csv(
	config["units"], dtype=str, sep="\t").set_index(["sample","lane","techrep","biorep"], drop=False)
###### sorting index to avoid PerformanceWarning: indexing past lexsort depth may impact performance #####
units.index.names = ["sample_id","lane_id","techrep_id","biorep_id"]
units.index = units.index.set_levels(
	[i.astype(str) for i in units.index.levels])  # enforce str in index
validate(units, schema="../schemas/units.schema.yaml")

##### wildcard constraints #####

wildcard_constraints:
	sample="|".join(samples.index),
	lane="|".join(units["lane"]),
	techrep="|".join(units["techrep"]),
	biorep="|".join(units["biorep"])

####### helpers ###########

def is_single_end(sample,lane,techrep,biorep):
	"""Determine whether unit is single-end."""
	fq2_present = pd.isnull(units.loc[(sample,lane,techrep,biorep), "fq2"])
	if isinstance(fq2_present, pd.core.series.Series):
		# if this is the case, get_fastqs cannot work properly
		raise ValueError(
			f"Multiple fq2 entries found for sample-lane-techrep-biorep combination {sample}-{lane}-{techrep}-{biorep}.\n"
			"This is most likely due to a faulty units.tsv file, e.g.\n"
			"Try checking your units.tsv for duplicates."
		)
	return fq2_present

def get_reads(wildcards):
	return get_seperate(**wildcards)

def get_seperate(sample,biorep,side):
	return units.loc[(sample,biorep), "fq{}".format(str(side))]

def get_fastqs(wildcards):
	"""Get raw FASTQ files from unit sheet."""
	if is_single_end(**wildcards):
		return units.loc[ (wildcards.sample, wildcards.lane, wildcards.techrep, wildcards.biorep), "fq1" ]
	else:
		u = units.loc[ (wildcards.sample, wildcards.unit), ["fq1", "fq2"] ].dropna()
		return [ f"{u.fq1}", f"{u.fq2}" ]


####### get raw data from units.tsv #######

def get_fastqs(wildcards):
	"""Get raw FASTQ files from unit sheet."""
	if is_single_end(**wildcards):
		return units.loc[ (wildcards.sample, wildcards.lane,wildcards.techrep,wildcards.biorep), "fq1" ]
	else:
		u = units.loc[ (wildcards.sample, wildcards.lane,wildcards.techrep,wildcards.biorep), ["fq1", "fq2"] ].dropna()
		return [ f"{u.fq1}", f"{u.fq2}" ]
####### get trimmed data #######

def get_trimmed(wildcards):
    """Get merged FASTQ files."""
    if is_single_end(**wildcards):
        return {'single' : expand("results/trimmed/{sample}{lane}{techrep}-{biorep}.fq.gz", **wildcards)}
    else:
        return { 'r1': expand("results/trimmed/{sample}{lane}{techrep}-{biorep}-1.fq.gz", **wildcards) ,'r2' : expand("results/trimmed/{sample}{lane}{techrep}-{biorep}-2.fq.gz" , **wildcards)}

####### get bam files #######
def get_bam(wildcards):
	return expand("results/alignment/{sample}{lane}{techrep}-{biorep}/{sample}{lane}{techrep}-{biorep}_bismark_bt2.bam",lane=get_lanes(wildcards),**wildcards)

def get_sample_list(samples):
	return samples['sample'].tolist()

####### step status  #######

def is_wanted(wildcards):
	return config_element['activate'] in {"true","True"}

# def to_merge_or_not_to_merge(wildcards):
# 	rows = units.loc[(units['sample'] == wildcards.sample) & (units['biorep'] == wildcards.biorep)]['fq1']
# 	if len(rows) > 1:
# 		return rows

# def get_genome_directory(wildcards):
# 	return config['resources']['ref']['genome']


#### returns lanes for each sample-techrep-biorep combination ####
def get_lanes(wildcards):
	samples= units['sample'] == wildcards.sample
	bioreps= units['biorep'] == wildcards.biorep
	techreps= units['techrep'] == wildcards.techrep
	return units[samples & bioreps & techreps].lane.tolist()
#### returns each line or unit of unique sample-lane-techrep-biorep combination ####
def get_unit():
	return units[["sample","lane","techrep","biorep"]].itertuples()


#### returns each combination of sample-techrep-biorep####
def get_merged():
	return units[["sample","techrep","biorep"]].itertuples()
