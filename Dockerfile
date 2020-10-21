FROM continuumio/miniconda3:latest

# MAINTAINER Skander Hatira skander.hatira@inrae.fr
LABEL Name=dmr-pipe Version=1.

ARG USERNAME
ARG USER_ID
ARG GROUP_ID

########################### Copy Necessary Files For Image ##########################
WORKDIR /dmr-pipe
COPY . /dmr-pipe

################### Config Conda And Create Snakemake Environment ###################
RUN conda config --set always_yes yes --set changeps1 no \
	&& conda config --add channels conda-forge \
	&& conda config --add channels bioconda \
	&& conda create -n snakemake snakemake \
	&& conda clean -a 

RUN	addgroup --gid $GROUP_ID $USERNAME \
	&& adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USERNAME \
	&& chown -R $USERNAME /dmr-pipe \
	&& chmod -R 755 /dmr-pipe \
	&& chown -R $USERNAME /opt/conda/ \
	&& chmod -R 755 /opt/conda/
	
USER $USERNAME

#################################### Run dmr-pipe ###################################
ENTRYPOINT [ "conda" , "run" , "-n" ,"snakemake","snakemake" ]
