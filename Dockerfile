FROM mhart/alpine-node:latest

MAINTAINER miniers <m@lk.mk>

ENV S6_OVERLAY_VERSION v1.21.2.2 
ENV SS_VER 3.1.3
ENV SS_URL https://github.com/shadowsocks/shadowsocks-libev/archive/v$SS_VER.tar.gz
ENV SS_DIR shadowsocks-libev-$SS_VER

RUN apk add --update --no-cache curl tzdata && \
    curl -sSL https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz \
    | tar xfz - -C / && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del curl tzdata && \
    rm -rf /var/cache/apk/*
    
RUN set -ex \
    && apk add --no-cache libcrypto1.0 \
                          libev \
                          libsodium \
                          mbedtls \
                          c-ares \
                          pcre \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        asciidoc \
        xmlto \
        gettext-dev \
        build-base \
        curl \
        libev-dev \
        unzip \
        c-ares-dev \
        libtool \
        linux-headers \
        openssl-dev \
        libsodium-dev \
        mbedtls-dev \
        pcre-dev \
        tar \
        wget \
        git \
    && curl -ksSL $SS_URL | tar xz \
    && cd $SS_DIR \
        && curl -ksSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset \
        && curl -ksSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork \
        && curl -ksSL https://github.com/shadowsocks/libbloom/archive/master.tar.gz | tar xz --strip 1 -C libbloom \
        && ./autogen.sh \
        && ./configure --disable-documentation \
        && make install \
        && cd .. \
    && git config --global http.sslVerify false \
    && git clone https://github.com/shadowsocks/simple-obfs \
    && cd simple-obfs \
    && git submodule update --init --recursive \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf simple-obfs \
    && apk del .build-deps \
    && rm -rf client_linux_amd64 \
        $SS_DIR \
        simple-obfs-$SIMPLE_OBFS_VERSION \
        /var/cache/apk/*

RUN apk add --no-cache  git \ 
    && git clone https://github.com/miniers/shadowsocks-manager.git /ssmgr \
    && cd /ssmgr \
    && git checkout miniers \
    && npm i

ADD root /

EXPOSE 4001 80 38000-38100

ENTRYPOINT ["/init"]