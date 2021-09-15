
#!/bin/bash
unlock=$1
[ -e biseps.txt ] && rm -- biseps.txt
[ -e failed.lock ] && rm -- failed.lock
if [[ $unlock == true ]]; then
snakemake --profile config/profiles/localComparison --unlock &>> biseps.txt 
fi
source exec_scripts/script.sh 
snakemake --profile config/profiles/localComparison &>> biseps.txt 
snakemake --profile config/profiles/localComparison  --report report.html &>> biseps.txt 
if [ $? -ne 0 ]
then
   touch failed.lock
fi
