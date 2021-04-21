rule methylation_extraction_bismark:
	input:
		rules.deduplicate.output[0]
	output:
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.TechRep_{techrep}.BioRep_{biorep}.deduplicated.CX_report.txt",
		outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.TechRep_{techrep}.BioRep_{biorep}.deduplicated_splitting_report.txt',
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}.TechRep_{techrep}.BioRep_{biorep}.deduplicated.M-bias.txt",
		temp(expand(outdir+"results/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}/methylation_extraction_bismark/{context}_context_{{sample}}.TechRep_{{techrep}}.BioRep_{{biorep}}.deduplicated.txt",context = ['CHH','CHG','CpG']))
	conda:
		"../envs/bisgraph.yaml"
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}.TechRep_{techrep}.BioRep_{biorep}-methylation_extraction_bismark.log"
	params:
		#genome directory
		genome=get_abs(config['resources']['ref']['genome']),
		# optional parameters
		out_dir=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/",
		instances= lambda wildcards : config['params']['bismark']['instances'],
		# flags
		flags= lambda wildcards : unpack_boolean_flags(config['params']['methylation_extraction']['bool_flags']),
		extra= lambda wildcards :  config['params']['methylation_extraction']['extra'] #include_overlap? #get_p_s_flag?
	resources:
		cpus=lambda wildcards : 4*config['params']['bismark']['instances'],
		mem_mb= int(genomeSize*11),
		time_min=5440
	shell:
		"bismark_methylation_extractor  {input}  --genome_folder {params.genome} {params.flags} -p  --parallel {params.instances} -o {params.out_dir}  {params.extra} 2> {log} "
