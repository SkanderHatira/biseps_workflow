#!/bin/bash
#SBATCH --job-name=snakemake
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1000
#SBATCH --output=last.txt

source script.sh 
snakemake --profile config/profiles/slurm --unlock
snakemake --profile config/profiles/slurm
