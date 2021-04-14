#!/bin/bash
#SBATCH --job-name=smkgddh
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=100
#SBATCH --output=rerun.txt

. /local/env/envsnakemake-5.20.1.sh
snakemake --profile config/profiles/slurm --unlock
time snakemake --profile config/profiles/slurm 
