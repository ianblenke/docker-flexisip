FROM debian:wheezy
MAINTAINER Ian Blenke <ian@blenke.com>

ENV VERSION 1.0.5-17

# Prepare the Debian non-free and backports repositories for dependencies
RUN echo deb http://http.us.debian.org/debian wheezy non-free > /etc/apt/sources.list.d/non-free.list
RUN echo deb http://http.us.debian.org/debian wheezy-backports main > /etc/apt/sources.list.d/backports.list
RUN apt-get update -y

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget snmp-mibs-downloader snmp

# Prepare the Linphone repository
RUN echo deb http://linphone.org/snapshots/debian wheezy main > /etc/apt/sources.list.d/belledonne.list
RUN wget -O - -q http://linphone.org/snapshots/debian/repo.gpg.key | apt-key add -
RUN apt-get update -y

# Install the specific version we're building this image for
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y bc-ortp bc-flexisip=$VERSION

# Add it to the default path
ENV PATH=$PATH:/opt/belledonne-communications/bin

WORKDIR /opt/belledonne-communications

# Generate a default configuration
RUN flexisip --dump-default all > /etc/flexisip/flexisip.conf

# https://wiki.linphone.org/wiki/index.php/Flexisip:snmp
RUN mkdir -p ~/.snmp/mibs /etc/snmp ; \
    flexisip --dump-mibs > ~/.snmp/mibs/fleximib.txt

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y snmpd

COPY snmpd.conf /etc/snmp/snmpd.conf 

VOLUME /etc/flexisip

CMD flexisip -c /etc/flexisip/flexisip.conf

