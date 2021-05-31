
#!/bin/bash
profile=$1

source script.sh
snakemake --profile config/profiles/local --unlock
snakemake --profile config/profiles/local 
