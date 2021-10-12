
#!/bin/bash
unlock=$1
[ -e biseps.txt ] && rm -- biseps.txt
[ -e failed.lock ] && rm -- failed.lock
tr -d '\15\32' < exec_scripts/script.sh > exec_scripts/script.sh 
source exec_scripts/script.sh 
if [[ $unlock == true ]]; then
snakemake --profile config/profiles/local --unlock &>> biseps.txt 
fi

snakemake --profile config/profiles/local &>> biseps.txt 
snakemake --profile config/profiles/local --report report.html   &>> biseps.txt
if [ $? -ne 0 ]
then
   touch failed.lock
fi
