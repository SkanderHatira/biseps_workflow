rule methylation_extraction_bismark:
	input:
		rules.deduplicate.output[0]
	output:
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt",
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.bedGraph.gz",
		report(expand(outdir+"results/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}/methylation_extraction_bismark/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}.deduplicated.M-bias_{R}.png", R=["R1","R2"]),category="M-Bias"),
		temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.bismark.cov.gz"),
		outdir+'results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated_splitting_report.txt',
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.M-bias.txt",
		temp(expand(outdir+"results/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}/methylation_extraction_bismark/{context}_context_{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}.deduplicated.txt",context = ['CHH','CHG','CpG']))
	conda:
		"../envs/bisgraph.yaml" if config["platform"] == 'linux' else '../envs/empty.yaml'
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-TechRep_{techrep}-BioRep_{biorep}-methylation_extraction_bismark.log"
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
rule cgmap:
	input:
		rules.methylation_extraction_bismark.output[0]
	output:
		outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.CGmap.gz",
	conda:
		"../envs/methget.yaml" if config["platform"] == 'linux' else '../envs/empty.yaml'
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-TechRep_{techrep}-BioRep_{biorep}-methgetCGmap.log"
	resources:
		mem_mb= lambda  Input : int(genomeSize*11*8*len(Input)),
	shell:
		"python workflow/scripts/methcalls2cgmap.py -n {input} -f bismark"
rule CXtoBigWig:
	input:
		cx=rules.methylation_extraction_bismark.output[0],
		index=config['resources']['ref']['genome'] + ".fai",
	output:
		sort=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.sorted"),
		bigwigs=temp(expand(outdir+"results/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}/methylation_extraction_bismark/{{sample}}-TechRep_{{techrep}}-BioRep_{{biorep}}.deduplicated.CX_report.txt.sorted.bw.{context}", context= {"cg","chg","chh"})),
	conda:
		"../envs/tabix.yaml" if config["platform"] == 'linux' else '../envs/empty.yaml'
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-TechRep_{techrep}-BioRep_{biorep}-cxtobigwig.log"
	params:
	shell:
		"sort -k1,1 -k2,2n {input.cx} > {output.sort};"
		"python3 workflow/scripts/bismark_to_bigwig_pe.py {input.index} {output.sort} 2> {log}"				
rule bedGraphToBigWig:
	input:
		bedgraph=rules.methylation_extraction_bismark.output[1],
		index=config['resources']['ref']['genome'] + ".fai",
	output:
		unzip=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.bedGraph"),
		sort=temp(outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.sorted.bedGraph"),
		bw=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.sorted.bedGraph.bw",
	conda:
		"../envs/tabix.yaml" if config["platform"] == 'linux' else '../envs/empty.yaml'
	log:
		outdir+"logs/{sample}-TechRep_{techrep}-BioRep_{biorep}/{sample}-TechRep_{techrep}-BioRep_{biorep}-bedgraphtobigwig.log"
	params:
	shell:
		"gunzip {input.bedgraph};"
		"sed -i '1d' {output.unzip};"
		"sort -k1,1 -k2,2n {output.unzip} > {output.sort}; "
		"bedGraphToBigWig   {output.sort} {input.index} {output.bw}  &> {log}"				
rule renameBigWig:
	input:
		cg=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.sorted.bw.cg",
		chg=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.sorted.bw.chg",
		chh=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.sorted.bw.chh",
	output:
		cg=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.sorted.cg.bw",
		chg=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.sorted.chg.bw",
		chh=outdir+"results/{sample}-TechRep_{techrep}-BioRep_{biorep}/methylation_extraction_bismark/{sample}-TechRep_{techrep}-BioRep_{biorep}.deduplicated.CX_report.txt.sorted.chh.bw",
	shell:
		"mv {input.cg} {output.cg};"
		"mv {input.chg} {output.chg};"
		"mv {input.chh} {output.chh};"
