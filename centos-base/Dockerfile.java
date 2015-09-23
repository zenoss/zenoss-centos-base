FROM zenoss/centos-base:1.0.1
MAINTAINER Zenoss <dev@zenoss.com>

RUN yum -y install java-1.7.0-openjdk-headless && /sbin/scrub.sh
ENV JAVA_HOME /usr/lib/jvm/jre