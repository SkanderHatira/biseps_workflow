
#!/bin/bash

# snakemake --profile config/profiles/local --unlock
source exec_scripts/script.sh 
snakemake --profile config/profiles/local &> biseps.txt 
snakemake --profile config/profiles/local --report report.html   &>> biseps.txt 
