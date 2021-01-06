# Snakemake workflow: bissprop

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.23.0-brightgreen.svg)](https://snakemake.bitbucket.io)

This is a `snakemake` pipeline for bisulfite sequencing data, it implements:
1. 	Adapter trimming and quality check
2.	Quality reports and statistics (`fastqc`+ `multiqc`)
3.	Methylation extraction with `bismark` (`bowtie2`/`hisat2` as aligners)
4.	DMR identification with `dmrcaller` (in all contexts) : in progress

## Authors

* Skander Hatira (@skanderhatira)

## Usage

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) repository and, if available, its DOI (see above).

### Step 1: Obtain a copy of this workflow

[Clone](https://help.github.com/en/articles/cloning-a-repository) the newly created repository to your local system, into the place where you want to perform the data analysis.

	git clone git@forgemia.inra.fr:skander.hatira/bissprop.git

### Step 2: Configure workflow

Configure the workflow according to your needs via editing the files in the `config/` folder. Adjust `config.yaml` to configure the workflow execution, and `samples.tsv`, `units.tsv` to specify your sample setup.

### Step 3: Install Snakemake

Install Snakemake using [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html):

    conda create -c bioconda -c conda-forge -n snakemake snakemake

For installation details, see the [instructions in the Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

### Step 4: Execute workflow

Activate the conda environment:

    conda activate snakemake

Test your configuration by performing a dry-run via

    snakemake --use-conda -n

Execute the workflow locally via

    snakemake --use-conda --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --use-conda --cluster qsub --jobs 100

or

    snakemake --use-conda --drmaa --jobs 100


in combination with any of the modes above.
See the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executable.html) for further details.

### Step 5: Investigate results

After successful execution, you can create a self-contained interactive `.html` report with all results via:

    snakemake --report report.html

### Build docker image
 
A docker image of this workflow can be built from the repository by running this command:

    docker build -t bissprop --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) --build-arg USERNAME=$USER .

To run this container with your data you need to bind volumes specyfing raw data, configuration files, and necessary resources
 
## Testing

The `.test` directory contains subsampled `.fastq` files for two samples (multi-lane + biological replicates) and a `.fasta` file containing genome sequence from [NCBI](https://www.ncbi.nlm.nih.gov/nuccore/NC_041792.1?report=fasta).

You can also specify your own config.yaml and provide necessary data (`units.tsv`,`samples.tsv`).

To test the pipeline you have to be on a `conda` enabled machine :

    snakemake --cores $N --use-conda --configfile .test/config/config.yaml

or a `docker` enabled machine to build and run the image with a mounted folder containing necessary data and configuration files pointing to that data:

    docker run --mount type=bind,src="$(pwd)/.test",dst=/BiSSProP/.test,readonly bissprop \ 
	
	--cores $N --use-conda --configfile .test/config/config.yaml 

Note that your output data won't be accessible as it isn't mounted/stored in a `docker` `volume`, refer to `docker` [documentation](https://docs.docker.com/storage/volumes/) on best practices to persist data in running containers.


