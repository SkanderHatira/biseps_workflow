
#!/bin/bash
unlock=$1
[ -e biseps.txt ] && rm -- biseps.txt
[ -e failed.lock ] && rm -- failed.lock

if [[ $unlock ]]; then
snakemake --profile config/profiles/local --unlock &>> biseps.txt 
fi
source exec_scripts/script.sh 
snakemake --profile config/profiles/local &>> biseps.txt 
snakemake --profile config/profiles/local --report report.html   &>> biseps.txt
if [ $? -ne 0 ]
then
   touch failed.lock
fi
