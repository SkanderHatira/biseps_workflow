
#!/bin/bash

source script.sh
snakemake --profile config/profiles/local --unlock
snakemake --profile config/profiles/local 
