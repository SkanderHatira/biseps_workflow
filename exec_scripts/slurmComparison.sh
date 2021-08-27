#!/bin/bash
#SBATCH --job-name=biseps
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=1000
#SBATCH --output=biseps.txt
unlock=$1
[ -e failed.comparison ] && rm -- failed.comparison
source exec_scripts/script.sh 
if [[ $unlock ]]; then
snakemake --profile config/profiles/slurmComparison --unlock
fi
snakemake --profile config/profiles/slurmComparison
snakemake --profile config/profiles/slurmComparison --report report.html

if [ $? -ne 0 ]
then
   touch failed.comparison
fi
