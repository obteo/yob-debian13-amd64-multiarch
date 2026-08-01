# syntax=docker/dockerfile:1

FROM debian:13-slim

ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source="https://github.com/obteo/yob-debian13-amd64-multiarch" \
      org.opencontainers.image.title="YOB Debian 13 AMD64 Multiarch" \
      org.opencontainers.image.description="Debian 13 amd64 runtime with i386 compatibility libraries for legacy game servers"

# Native amd64 container with the i386 runtime libraries required by
# legacy 32-bit game server binaries and plugins.
RUN set -eux; \
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
    rm -rf /var/lib/apt/lists/*

# Legacy 32-bit compatibility files used by older game servers.
COPY libcxa.so.1 /tmp/libcxa.so.1
COPY libstdc++5_3.3.6-34_i386.deb /tmp/libstdc++5.deb

RUN set -eux; \
    echo "ecd1a774964c28eb22dcfadcdba2cbb3d0f048ebc801a72b0a23370f655a666b  /tmp/libcxa.so.1" | sha256sum -c -; \
    echo "55d14a8e77551f500b61893a006d960872a35a29229c782acfa7f8cd48d21063  /tmp/libstdc++5.deb" | sha256sum -c -; \
    apt-get update; \
    apt-get install -y --no-install-recommends /tmp/libstdc++5.deb; \
    install -D -m 0644 /tmp/libcxa.so.1 /usr/lib/i386-linux-gnu/libcxa.so.1; \
    ldconfig; \
    test -f /usr/lib/i386-linux-gnu/libcxa.so.1; \
    test -e /usr/lib/i386-linux-gnu/libstdc++.so.5; \
    rm -f /tmp/libcxa.so.1 /tmp/libstdc++5.deb; \
    rm -rf /var/lib/apt/lists/*

# Pterodactyl runtime user. This retains the previous /home/container layout.
RUN useradd --create-home \
            --home-dir /home/container \
            --shell /bin/bash \
            container

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

USER container

ENV USER=container \
    HOME=/home/container

WORKDIR /home/container

CMD ["/bin/bash", "/entrypoint.sh"]
