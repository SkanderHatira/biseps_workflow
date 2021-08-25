
#!/bin/bash

# snakemake --profile config/profiles/localComparison --unlock
source exec_scripts/script.sh 
snakemake --profile config/profiles/localComparison &> biseps.txt 
snakemake --profile config/profiles/localComparison  --report report.html &>> biseps.txt 
