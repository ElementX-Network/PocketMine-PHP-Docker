FROM ubuntu:22.04

ARG PM_VERSION
ARG COMPILE_SH_ARGS="-f -g"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        build-essential \
        m4 \
        gzip \
        bzip2 \
        bison \
        git \
        cmake \
        autoconf \
        automake \
        pkg-config \
        libtool \
        libtool-bin \
        re2c

RUN mkdir /build
WORKDIR /build
COPY compile.sh .

RUN ./compile.sh -t linux64 -j ${THREADS:-$(grep -E ^processor /proc/cpuinfo | wc -l)} -P ${PM_VERSION} ${COMPILE_SH_ARGS} \
    && mv bin/php7 /usr/php \
    && echo "extension_dir=\"$(find /usr/php -name *debug-zts*)\"" >> /usr/php/bin/php.ini

FROM ubuntu:22.04

COPY --from=0 /usr/php /usr/php

RUN ln -s /usr/php/bin/php /usr/bin/php
