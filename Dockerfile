FROM continuumio/miniconda3:4.8.2

# MAINTAINER Skander Hatira skander.hatira@inrae.fr
LABEL Name=dmr-pipe Version=1.0


################### Config Conda And Create Snakemake Environment ###################

RUN conda config --set always_yes yes --set changeps1 no \
	&& conda config --add channels conda-forge \
	&& conda config --add channels bioconda \
	&& conda create -q -n snakemake snakemake>=5.23.0 \
	&& conda clean -a 
	
########################### Copy Necessary Files For Image ##########################

WORKDIR /dmr-pipe
COPY . /dmr-pipe

#################################### Run dmr-pipe ###################################

ENTRYPOINT [ "conda" , "run" , "-n" ,"snakemake","snakemake" ]
# CMD ["-n","--configfile",".test/config/config.yaml" ]
