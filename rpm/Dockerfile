#
# FPM Dockerfile
#
# https://github.com/dockerfile/fpm
#

# Pull base image.
FROM dockerfile/fpm

# Install FPM.

RUN apt-get update -q
RUN apt-get install -y -q rpm

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]