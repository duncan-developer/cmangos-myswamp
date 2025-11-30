FROM ubuntu:24.04 AS builder
# Install dependencies
RUN apt update && apt install -y \
    build-essential \
    gcc \
    g++-12 \
    automake \
    git-core \
    autoconf \
    make \
    patch \
    libmysql++-dev \
    mysql-server \
    libtool \
    libssl-dev \
    grep binutils \
    zlib1g-dev \
    libbz2-dev \
    cmake \
    libboost-all-dev

FROM builder AS downloader

ENV WORK_DIR=/home/cmangos
ENV MANGOS_SOURCE_DIR=${WORK_DIR}/mangos
ENV BUILD_DIR=${WORK_DIR}/build
ENV RUN_DIR=${WORK_DIR}/run
ENV SCRIPT_DIR=/home/scripts

WORKDIR ${WORK_DIR}

## Download source files
RUN git clone https://github.com/cmangos/mangos-classic.git ${MANGOS_SOURCE_DIR}
WORKDIR ${MANGOS_SOURCE_DIR}
RUN git clone https://github.com/cmangos/classic-db.git

FROM downloader AS compiler
## Copy and setup bash scripts
RUN mkdir ${SCRIPT_DIR}
COPY ./compile-mangos.sh ${SCRIPT_DIR}/compile-mangos.sh
RUN chmod +x ${SCRIPT_DIR}/compile-mangos.sh

WORKDIR ${BUILD_DIR}
RUN ${SCRIPT_DIR}/compile-mangos.sh ${RUN_DIR}

# Rename config files to correct name
WORKDIR ${RUN_DIR}/etc
RUN cp mangosd.conf.dist mangosd.conf && \
cp realmd.conf.dist realmd.conf && \
cp anticheat.conf.dist anticheat.conf

FROM compiler AS environment

ENTRYPOINT [ "sleep", "1000"]