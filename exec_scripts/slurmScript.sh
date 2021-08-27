#!/bin/bash
#SBATCH --job-name=biseps
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1000
#SBATCH --output=biseps.txt
unlock=$1

source exec_scripts/script.sh 
if [[ $unlock ]]; then
snakemake --profile config/profiles/localComparison --unlock &>> biseps.txt 
fi
snakemake --profile config/profiles/slurm
snakemake --profile config/profiles/slurm --report report.html
