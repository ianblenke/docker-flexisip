FROM centos:7
MAINTAINER Ian Blenke <ian@blenke.com>

ENV VERSION 1.0.8

ADD Belledonne.repo /etc/yum.repos.d/Belledonne.repo

RUN yum -y update; yum clean all
RUN yum -y install epel-release protobuf
RUN mkdir -p /opt/belledonne-communications
RUN sed -i -e 's/keepcache=0/keepcache=1/' /etc/yum.conf ; \
    yum -y install epel-release wget net-snmp bc-flexisip bc-sofia-sip ; \
    rpm -Uvh --force /var/cache/yum/x86_64/7/Belledonne/packages/*.rpm ; \
    yum clean all

# Add it to the default path
ENV PATH=$PATH:/opt/belledonne-communications/bin

WORKDIR /opt/belledonne-communications

## Generate a default configuration
RUN rpm -ql bc-flexisip
RUN flexisip --dump-default all > /etc/flexisip/flexisip.conf

# https://wiki.linphone.org/wiki/index.php/Flexisip:snmp
RUN mkdir -p ~/.snmp/mibs /etc/snmp ; \
    flexisip --dump-mibs > ~/.snmp/mibs/fleximib.txt

COPY snmpd.conf /etc/snmp/snmpd.conf 

VOLUME /etc/flexisip

CMD flexisip -c /etc/flexisip/flexisip.conf

