from snakemake.utils import validate
import pandas as pd
import os


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
outdir = config['general']['outdir']
##### wildcard constraints #####

wildcard_constraints:
	sample="|".join(samples.index),
	lane="|".join(units["lane"]),
	techrep="|".join(units["techrep"]),
	biorep="|".join(units["biorep"])
	
####### general config #####
benchmark = config['general']['benchmark']

####### helpers ###########
genomeSize= os.path.getsize(config['resources']['ref']['genome'])/(1024*1024)
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

def unpack_boolean_flags(bool_flags):
	flags = ""
	for f in bool_flags:
		if bool_flags[f'{f}'] in {'true','True'} :
			flags = flags + f'--{f} '
	return flags

#### Quick-run vs Full-run ####	
def get_raw(wildcards):
	if is_activated(config['steps']['subsample']):
		return get_sub(wildcards)
	return get_merged_data(wildcards)

def get_data(wildcards):
	if is_activated(config["steps"]["trimming"]):
		return get_trimmed(wildcards)
	return get_raw(wildcards)
####### get file extension #######

def get_ext(wildcards):
	if is_single_end(**wildcards):
		ext1 = os.path.splitext(units.loc[ (wildcards.sample, wildcards.lane,wildcards.techrep,wildcards.biorep), "fq1" ])[1]
		return {'s' : f"{ext1}" }
	else:
		ext1 = os.path.splitext(units.loc[(wildcards.sample, wildcards.lane,wildcards.techrep,wildcards.biorep), "fq1" ])[1]
		ext2 = os.path.splitext(units.loc[(wildcards.sample, wildcards.lane,wildcards.techrep,wildcards.biorep), "fq2" ])[1]
		return { 'r1' : f"{ext1}", 'r2' : f"{ext2}" }
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
    return { 'r1': expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-1.fq", **wildcards) ,'r2' : expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/trimmed/{sample}-2.fq" , **wildcards)}
####### get merged data #######

def get_merged_data(wildcards):
	return { 'r1': expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-1.fq", **wildcards) 
	,'r2' : expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/merged/{sample}-2.fq" , **wildcards)}

####### get bam files #######
def get_bam_pe(wildcards):
	return expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/alignment_bismark/{sample}-bismark_bt2_pe.bam",**wildcards)

####### step status  #######
def is_activated(config_element):
    return config_element['activated'] in {"true","True"}

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

#### returns unique combinations of sample-techrep-biorep ####
def get_merged():
	return list(set(units[["sample","techrep","biorep"]].itertuples(index=False)))

#### returns CX report for treatment + control #### 

def get_CX_reports(wildcards):
	return expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.deduplicated.CX_report.txt",biorep=get_bioreps(wildcards),**wildcards)
	

# returns subsamples of your data to run the pipeline on, ideal for making sure your configuration doesn't break the pipeline e.g not respecting input files type/ data type of parameters... 
def get_sub(wildcards):
        return { 'r1': expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-1.fq", **wildcards) ,
		'r2' : expand(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/subsampled/{sample}-2.fq" , **wildcards)}


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
	return os.path.dirname(os.path.abspath(relative_path))
