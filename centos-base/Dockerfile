FROM centos:centos7
MAINTAINER Zenoss <dev@zenoss.com>

ENV TERM xterm

# Update packages
RUN yum --setopt=tsflags="nodocs" --exclude=systemd\* --exclude=iputils\* update -y && \
    yum clean all

# Install some useful tools
RUN yum install -y --setopt=tsflags="nodocs" \
        vim-minimal                          \
        file                                 \
        binutils                             \
        telnet                               \
        htop                                 \
        bash-completion                      \
        hostname                             \
        nc                                   \
        openssh-clients                      \
        which                                \
        zip                                  \
        traceroute                           \
        wget                                 \
        lsof                                 \
        curl                                 \
        nano                                 \
        tree                                 \
        strace                               \
        tcpdump                              \
        bind-utils                           \
        net-tools                            \
        unzip                                \
        sysstat                              \
        tmux                                 \
    && yum clean all

# Install Python utilities
RUN wget -qO- https://bootstrap.pypa.io/get-pip.py | python; \
    pip install httpie

# Install setuser script
RUN wget -q https://raw.githubusercontent.com/phusion/baseimage-docker/master/image/bin/setuser -O /sbin/setuser && \
    sed -ie 's/python3/python/' /sbin/setuser && \
    chmod a+x /sbin/setuser

# Install jq to work with JSON
RUN wget -q https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/bin/jq && \
    chmod a+x /usr/bin/jq