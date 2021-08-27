
#!/bin/bash
unlock=$1
if [[ $unlock ]]; then
snakemake --profile config/profiles/test --unlock &>> biseps.txt 
fi
# snakemake --profile config/profiles/local --unlock
source exec_scripts/script.sh 
snakemake --profile config/profiles/test &>> biseps.txt 
snakemake --profile config/profiles/test --report report.html   &>> biseps.txt 
