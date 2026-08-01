# syntax=docker/dockerfile:1

FROM debian:13-slim

ARG DEBIAN_FRONTEND=noninteractive

# Legacy binary checksums:
# libcxa.so.1:
# ecd1a774964c28eb22dcfadcdba2cbb3d0f048ebc801a72b0a23370f655a666b
#
# libstdc++5_3.3.6-34_i386.deb:
# 55d14a8e77551f500b61893a006d960872a35a29229c782acfa7f8cd48d21063

COPY libcxa.so.1 /tmp/libcxa.so.1
COPY libstdc++5_3.3.6-34_i386.deb /tmp/libstdc++5.deb

RUN set -eux; \
    echo "ecd1a774964c28eb22dcfadcdba2cbb3d0f048ebc801a72b0a23370f655a666b  /tmp/libcxa.so.1" \
        | sha256sum -c -; \
    echo "55d14a8e77551f500b61893a006d960872a35a29229c782acfa7f8cd48d21063  /tmp/libstdc++5.deb" \
        | sha256sum -c -; \
    dpkg --add-architecture i386; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bash \
        wget \
        curl \
        ca-certificates \
        tar \
        xz-utils \
        libc6:i386 \
        libgcc-s1:i386 \
        libstdc++6:i386 \
        libcurl4t64:i386 \
        libncurses6:i386 \
        libtinfo6:i386; \
    apt-get install -y --no-install-recommends /tmp/libstdc++5.deb; \
    install -m 0644 \
        /tmp/libcxa.so.1 \
        /usr/lib/i386-linux-gnu/libcxa.so.1; \
    ldconfig; \
    rm -f \
        /tmp/libcxa.so.1 \
        /tmp/libstdc++5.deb; \
    rm -rf /var/lib/apt/lists/*

RUN useradd \
        --create-home \
        --home-dir /home/container \
        --shell /bin/bash \
        container

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

USER container

ENV USER=container \
    HOME=/home/container

WORKDIR /home/container

CMD ["/entrypoint.sh"]