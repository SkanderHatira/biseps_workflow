#!/bin/bash
#SBATCH --job-name=smkFull
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=100
#SBATCH --output=last.txt

source script.sh
time snakemake --profile config/profiles/slurm --unlock
time snakemake --profile config/profiles/slurm
