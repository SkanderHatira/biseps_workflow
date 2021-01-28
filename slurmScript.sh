#!/bin/bash

. /local/env/envsnakemake-5.5.4.sh
snakemake --configfile config/config${SLURM_ARRAY_TASK_ID}.yaml --cores 40 --use-conda -k
