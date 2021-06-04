
#!/bin/bash
profile=$1
envname=$2

conda run -n $envname snakemake --profile config/profiles/local --unlock
conda run -n $envname snakemake --profile config/profiles/local 
