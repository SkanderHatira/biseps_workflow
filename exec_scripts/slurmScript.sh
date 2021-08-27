#!/bin/bash
#SBATCH --job-name=biseps
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1000
#SBATCH --output=biseps.txt
unlock=$1
[ -e failed.alignment ] && rm -- failed.alignment
source exec_scripts/script.sh 
if [[ $unlock ]]; then
snakemake --profile config/profiles/localComparison --unlock  
fi
snakemake --profile config/profiles/slurm
snakemake --profile config/profiles/slurm --report report.html
if [ $? -ne 0 ]
then
   touch failed.alignment
fi
