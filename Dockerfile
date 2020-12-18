# FROM continuumio/miniconda3:4.7.12-alpine
FROM continuumio/miniconda3:latest
USER root
# MAINTAINER Skander Hatira skander.hatira@inrae.fr
LABEL Name=BiSSProP Version=1.0

# ENV USERNAME bissprop
# ENV USER_ID 1005
# ENV GROUP_ID 1005

ARG USERNAME
ARG USER_ID
ARG GROUP_ID

########################### Copy Necessary Files For Image ##########################
WORKDIR /BiSSProP
COPY . /BiSSProP

################### Config Conda And Create Snakemake Environment ###################
RUN /opt/conda/bin/conda config --set always_yes yes --set changeps1 no --set add_pip_as_python_dependency no \
	&& /opt/conda/bin/conda create  -q  -c anaconda -c bioconda -c conda-forge -n snakemake snakemake \
	&& /opt/conda/bin/conda clean -a \
	# for use of continuumio/miniconda3:latest base image
	&& addgroup --gid $GROUP_ID $USERNAME \
	&& adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USERNAME \ 
	# for use of continuumio/miniconda3:4.7.12-alpine base image
	# && /usr/sbin/addgroup -g $GROUP_ID $USERNAME  \
	# && /usr/sbin/adduser -u $USER_ID -S $USERNAME -G $USERNAME \
	&& chown -R $USERNAME /BiSSProP \
	&& chmod -R 755 /BiSSProP \
	&& chown -R $USERNAME /opt/conda/ \
	&& chmod -R 755 /opt/conda/
	
USER $USERNAME

#################################### Run BiSSProP ###################################
ENTRYPOINT [ "/opt/conda/bin/conda" , "run" , "-n" ,"snakemake","snakemake"]
