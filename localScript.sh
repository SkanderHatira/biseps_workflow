
#!/bin/bash
envname=$1

conda run -n $envname snakemake --profile config/profiles/local --unlock
conda run -n $envname snakemake --profile config/profiles/local 
