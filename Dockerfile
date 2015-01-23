# LICENSE CDDL 1.0 + GPL 2.0
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for HTTP Server 12.1.3 
# 
# REQUIRED BASE IMAGE TO BUILD THIS IMAGE
# ---------------------------------------
# Make sure you have oraclelinux:7.0 Docker image installed.
# Visit for more info: http://public-yum.oracle.com/docker-images/
#
# REQUIRED FILES TO BUILD THIS IMAGE (not included with this distribution)
# ------------------------------------------------------------------------
# (1) fmw_12.1.3.0.0_ohs_linux64.bin
#     Download from http://www.oracle.com/technetwork/middleware/webtier/downloads/index.html 
#     and unzip
#
# REQUIRED FILES TO BUILD THIS IMAGE (not included with this distribution)
# ------------------------------------------------------------------------
# (1) Dockerfile
#     This file.
# (2) oraInst.loc
#     Needed by OHS installer. Contains information about Oracle repository.
# (3) ohs_standalone.rspa
#     Response file for silent installation.
# (4) create_standalone_domain.py
#     WLST script for standalone domain creation.
# (5) startOHS.sh
#     Script for running nodemanager and starting OHS instance.
# (6) startOHS.py
#     IHS instance starting WLST script.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run: 
#      $ sudo docker build -t oracle/ohs:12.1.3 .
#

# Pull base image
# ---------------
FROM oraclelinux:7.0

# Maintainer
# ----------
MAINTAINER Juraj Kazda <juraj.kazda@oracle.com>

# Environment variables required for this build (do NOT change)
ENV HTTP_BIN fmw_12.1.3.0.0_ohs_linux64.bin

# WLS Admin Password (you may change)
# This password is used for:
#  (a) 'oracle' user - nodemanager admin
#  (b) 'oracle' Linux user in this image
# -----------------------------------
ENV ADMIN_PASSWORD welcome1

# Setup required packages (unzip), filesystem, and oracle user
# ------------------------------------------------------------
# Enable this if behind proxy
# RUN sed -i -e '/^\[main\]/aproxy=http://proxy.com:80' /etc/yum.conf
RUN yum install -y libaio make gcc-* && \
    yum clean all && \
    mkdir /u01 && chmod a+xr /u01 && \ 
    useradd -b /home -m -s /bin/bash oracle && \ 
    echo oracle:$ADMIN_PASSWORD | chpasswd

# Add files required to build this image
ADD $HTTP_BIN /u01/
ADD ohs_standalone.rsp /u01/
ADD create_standalone_domain.py /u01/
ADD oraInst.loc /etc/

# Adjust file permissions, go to /u01 as user 'oracle' to proceed with WLS installation
RUN chown oracle:oracle -R /u01 && \
    chmod a+x /u01/$HTTP_BIN
USER oracle
WORKDIR /u01/

# Installation of OHS 
RUN ./$HTTP_BIN -silent -response /u01/ohs_standalone.rsp && \
    mkdir -p /u01/ohs/user_projects/domains && \
    /u01/ohs/ohs/common/bin/wlst.sh -skipWLSModuleScanning /u01/create_standalone_domain.py

# Add starting scripts, change its ownership
# (it's here because if you change them and rebuild container, the rebuild process will be fas
#  ter thanks to Docker's caching)
USER root
ADD startOHS.sh /u01/
ADD startOHS.py /u01/
RUN chown oracle:oracle /u01/start* 

USER oracle
# Make node manager to listen on all interfaces - it's listening just on 'localhost' by default, which means we won't be able to connect to it from host, just from guest
RUN sed -i 's/ListenAddress=.*/ListenAddress=0.0.0.0/' /u01/ohs/user_projects/domains/ohs_domain/nodemanager/nodemanager.properties
RUN chmod u+x /u01/startOHS.sh && \
    mv /u01/startOHS.sh /u01/ohs/user_projects/domains/ohs_domain/bin/ && \
    mv /u01/startOHS.py /u01/ohs/user_projects/domains/ohs_domain/bin/

# Expose Node Manager default port, and also default http/https ports for admin console
EXPOSE 5556 7777

WORKDIR /u01/ohs/user_projects/domains/ohs_domain/bin/

# Define default command to start bash. 
CMD ["/u01/ohs/user_projects/domains/ohs_domain/bin/startOHS.sh"]
