FROM continuumio/miniconda3:4.7.12-alpine
USER root
# MAINTAINER Skander Hatira skander.hatira@inrae.fr
LABEL Name=dmr-pipe Version=1.
ARG USERNAME
ARG USER_ID
ARG GROUP_ID

########################### Copy Necessary Files For Image ##########################
WORKDIR /dmr-pipe
COPY . /dmr-pipe

################### Config Conda And Create Snakemake Environment ###################
RUN /opt/conda/bin/conda config --set always_yes yes --set changeps1 no --set add_pip_as_python_dependency no \
	&& /opt/conda/bin/conda create  -q -c bioconda -c conda-forge -n snakemake snakemake-minimal pandas \
	&& /opt/conda/bin/conda clean -a \
	&& find /opt/conda/ -follow -type f -name '*.a' -delete \
	&& find /opt/conda/ -follow -type f -name '*.pyc' -delete \
	# for use of continuumio/miniconda3:latest base image
	# && addgroup --gid $GROUP_ID $USERNAME \
	# && adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $USERNAME \ 
	&& whoami \
	&& /usr/sbin/addgroup -g $GROUP_ID $USERNAME  \
	&& /usr/sbin/adduser -u $USER_ID -S $USERNAME -G $USERNAME \
	&& chown -R $USERNAME /dmr-pipe \
	&& chmod -R 755 /dmr-pipe \
	&& chown -R $USERNAME /opt/conda/ \
	&& chmod -R 755 /opt/conda/
	
USER $USERNAME

#################################### Run dmr-pipe ###################################
ENTRYPOINT [ "/opt/conda/bin/conda" , "run" , "-n" ,"snakemake","snakemake" ]
