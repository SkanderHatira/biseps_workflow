#!/bin/bash
#SBATCH --job-name=biseps
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1000
#SBATCH --output=biseps.txt
source exec_scripts/script.sh 
# snakemake --profile config/profiles/slurm --unlock
snakemake --profile config/profiles/slurm
