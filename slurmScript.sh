#!/bin/bash
#SBATCH --job-name=smkFull
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=100
#SBATCH --output=last.txt
script=$1

$script
snakemake --profile config/profiles/slurm --unlock
snakemake --profile config/profiles/slurm
