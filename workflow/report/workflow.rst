{{ something|safe }}

This run was performed with the following parameters :

1. units: {{ snakemake.config["units"] }}

2. outdir: {{ snakemake.config["general"]["outdir"] }}

3. benchmark: {{ snakemake.config["general"]["benchmark"] }}

4. threads: {{ snakemake.config["general"]["genome_preparation"]["threads"] }}

6. aligner:    {{ snakemake.config["general"]["genome_preparation"]["aligner"] }}

7. subsample: {{ snakemake.config["steps"]["subsample"]["activated"] }}

8. trimming:{{ snakemake.config["steps"]["trimming"]["activated"] }}

9. quality: {{ snakemake.config["steps"]["quality"]["activated"] }}

10. genome_preparation: {{ snakemake.config["steps"]["genome_preparation"]["activated"] }}

11. methylation_extraction_bismark: {{ snakemake.config["steps"]["methylation_extraction_bismark"]["activated"] }}

12. methylation_calling: {{ snakemake.config["steps"]["methylation_calling"]["activated"] }}

13. genome: {{ snakemake.config["resources"]["ref"]["genome"] }}

14. adapters: {{ snakemake.config["resources"]["adapters"] }}

15. trimmomatic-pe:

	1. trimmer: {{ snakemake.config["params"]["trimmomatic-pe"]["trimmer"] }}
	2. trimmer-options: {{ snakemake.config["params"]["trimmomatic-pe"]["trimmer-options"] }}
	3. threads: {{ snakemake.config["params"]["trimmomatic-pe"]["threads"] }}
	4. extra: {{ snakemake.config["params"]["trimmomatic-pe"]["extra"] }}

15. seqtk:

	1. seed: {{ snakemake.config["params"]["seqtk"]["seed"] }}
	2. size: {{ snakemake.config["params"]["seqtk"]["size"] }}
	3. extra: {{ snakemake.config["params"]["seqtk"]["extra"] }}

16. bismark:

	1. aligner: {{ snakemake.config["params"]["bismark"]["aligner"] }}
	2. aligner_options: {{ snakemake.config["params"]["bismark"]["aligner_options"] }}
	3. instances: {{ snakemake.config["params"]["bismark"]["instances"] }}	
	4. score_min: {{ snakemake.config["params"]["bismark"]["score_min"] }}	
	5. N: {{ snakemake.config["params"]["bismark"]["N"] }}	
	6. L: {{ snakemake.config["params"]["bismark"]["L"] }}	
	7. extra: {{ snakemake.config["params"]["bismark"]["extra"] }}	
	8. bool_flags:
		1. nucleotide_coverage: {{ snakemake.config["params"]["bismark"]["bool_flags"]["nucleotide_coverage"] }}
		2. no_dovetail: {{ snakemake.config["params"]["bismark"]["bool_flags"]["no_dovetail"] }}
		3. non_directional: {{ snakemake.config["params"]["bismark"]["bool_flags"]["non_directional"] }}

16. methylation_extraction:

	1. bool_flags:
		1. bedGraph: {{ snakemake.config["params"]["bismark"]["bool_flags"]["bedGraph"] }}
		2. CX: {{ snakemake.config["params"]["bismark"]["bool_flags"]["CX"] }}
		3. cytosine_report: {{ snakemake.config["params"]["bismark"]["bool_flags"]["cytosine_report"] }}
		4. comprehensive: {{ snakemake.config["params"]["bismark"]["bool_flags"]["comprehensive"] }}
		5. split_by_chromosome: {{ snakemake.config["params"]["bismark"]["bool_flags"]["split_by_chromosome"] }}


