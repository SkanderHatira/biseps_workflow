from snakemake.utils import validate
import pandas as pd
import os

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3:latest"

##### load config and sample sheets #####

# configfile: "config/config.yaml"
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
####### general config #####
benchmark = config['general']['benchmark']
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

####### get raw data from units.tsv #######

def get_fastqs(wildcards):
	"""Get raw FASTQ files from unit sheet."""
	if is_single_end(**wildcards):
		return { 's' : units.loc[ (wildcards.sample, wildcards.lane,wildcards.techrep,wildcards.biorep), "fq1" ]}
	else:
		u = units.loc[ (wildcards.sample, wildcards.lane,wildcards.techrep,wildcards.biorep), ["fq1", "fq2"] ].dropna()
		return { 'r1' : f"{u.fq1}", 'r2' : f"{u.fq2}" }
####### get trimmed data #######

def get_trimmed(wildcards):
    """Get merged FASTQ files."""
    if is_single_end(**wildcards):
        return {'single' : expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-L_{lane}.fq.gz", **wildcards)}
    else:
        return { 'r1': expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-L_{lane}-1.fq.gz", **wildcards) ,'r2' : expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-L_{lane}-2.fq.gz" , **wildcards)}
#### Quick-run vs Full-run ####	
def get_raw(wildcards):
	if is_activated(config['steps']['subsample']):
		return get_sub(wildcards)
	return get_fastqs(wildcards)

def get_data(wildcards):
	if is_activated(config["steps"]["trimming"]):
		return get_trimmed(wildcards)
	return get_raw(wildcards)

####### get bam files #######
def get_bam_bismark_pe(wildcards):
	return expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-L_{lane}-1_bismark_bt2_pe.bam",lane=get_lanes(wildcards),**wildcards)

def get_bam_bsmap_pe(wildcards):
	return expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bsmap/{sample}-L_{lane}-bsmap_pe.bsp",lane=get_lanes(wildcards),**wildcards)	

def get_sample_list(samples):
	return samples['sample'].tolist()

####### step status  #######

def is_wanted(wildcards):
	return config_element['activate'] in {"true","True"}

#### returns lanes for each sample-techrep-biorep combination ####
def get_lanes(wildcards):
	samples= units['sample'] == wildcards.sample
	bioreps= units['biorep'] == wildcards.biorep
	techreps= units['techrep'] == wildcards.techrep
	return units[samples & bioreps & techreps].lane.tolist()
def get_bioreps(wildcards):
	samples= units['sample'] == wildcards.sample
	techreps= units['techrep'] == wildcards.techrep
	return list(units[samples & techreps].biorep.unique())
#### returns each line or unit of unique sample-lane-techrep-biorep combination ####
def get_unit():
	return units[["sample","lane","techrep","biorep"]].itertuples()

#### returns each combination of sample-techrep-biorep ####
def get_merged():
	return units[["sample","techrep","biorep"]].itertuples()

#### returns CX report for treatment + control ####

def get_CX_reports(wildcards):
	return expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.CX_report.txt",biorep=get_bioreps(wildcards),**wildcards)

# returns subsamples of your data to run the pipeline on, ideal for making sure your configuration doesn't break the pipeline e.g not respecting input files type/ data type of parameters... 
def get_sub(wildcards):
    """Get merged FASTQ files."""
    if is_single_end(**wildcards):
        return {'single' : expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-L_{lane}.fq", **wildcards)}
    else:
        return { 'r1': expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-L_{lane}-1.fq", **wildcards) ,'r2' : expand("results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-L_{lane}-2.fq" , **wildcards)}

# for optional rules/steps to execute
def is_activated(config_element):
    return config_element['activate'] in {"true","True"}

def get_control_bioreps(wildcards):
	samples= units['sample'] == wildcards.control
	techreps= units['techrep'] == wildcards.ctechrep
	return list(units[samples & techreps].biorep.unique())
# identify control groups to perform pairwise comparisons with
def get_control():
	csamp = list(samples.loc[lambda samples: samples['condition'] == 'control']['sample'])
	control = units.loc[csamp][["sample","techrep"]].itertuples(index=False)
	return list(set(control))

# identify treatment groups to compute dmr for (against control group(s) )
def get_treatment():
	tsamp = list(samples.loc[lambda samples: samples['condition'] != 'control']['sample'])
	treatment = units.loc[tsamp][["sample","techrep"]].itertuples(index=False)
	return list(set(treatment))

# necessary for bismark extraction rule
def get_abs(relative_path):
	return os.path.abspath(relative_path)
def get_bsmap_ext():
	if config['alignment_tool']['tool'] == 'bsmap':
		return ['bam']