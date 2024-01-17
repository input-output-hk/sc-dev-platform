FROM ubuntu:24.04
WORKDIR /script

# Updating image and installing libs
RUN apt-get update \
&& apt-get -y upgrade \
&& apt-get -y install postgresql-client

# Cleaning image
RUN apt-get clean all && apt-get autoclean all

ADD replicate.sh .
