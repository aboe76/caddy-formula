FROM ubuntu:16.04
MAINTAINER Kacey Cole <kcole@izeni.com>

# Fetch system deps
RUN apt-get update && apt-get upgrade -y -o DPkg::Options::=--force-confold

RUN apt-get install -y python-software-properties software-properties-common wget
RUN wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
RUN echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list
RUN apt-get update
RUN apt-get install -y salt-minion

CMD /usr/bin/salt-minion --log-level=error
