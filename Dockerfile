FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG GE_PROTON_VERSION=GE-Proton11-9
ARG GE_PROTON_SHA512=30160946a5e4ffdf1f29d6f83a3d27108f6aa71b6aa59095b2c2260fe3a003b62acf8fdcb02a3dfc602b28473f5679d8a3eaee5a8adb141c1dfa01c42888da2d

LABEL org.opencontainers.image.source="https://github.com/CappyRedBeard/pterodactyl-enshrouded-proton" \
      org.opencontainers.image.description="Ubuntu 24.04 and GE-Proton runtime for Enshrouded on Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        alsa-tools \
        cabextract \
        ca-certificates \
        curl \
        dbus \
        file \
        fontconfig \
        gnutls-bin \
        iproute2 \
        lib32gcc-s1 \
        libao-common \
        libasound2t64 \
        libfontconfig1:i386 \
        libfreetype6:i386 \
        libgdiplus \
        libncurses6 \
        libntlm0 \
        libpulse-dev \
        libpulse0 \
        libvulkan1 \
        libvulkan1:i386 \
        libx11-6:i386 \
        libxext6:i386 \
        locales \
        numactl \
        pulseaudio \
        python3 \
        python3-pip \
        python3-setuptools \
        tini \
        wget \
        winbind \
        xauth \
        xvfb \
    && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --home-dir /home/container container

RUN curl -fL --retry 3 \
        -o /tmp/${GE_PROTON_VERSION}-x86_64.tar.gz \
        https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${GE_PROTON_VERSION}/${GE_PROTON_VERSION}-x86_64.tar.gz \
    && echo "${GE_PROTON_SHA512}  /tmp/${GE_PROTON_VERSION}-x86_64.tar.gz" | sha512sum --check --strict \
    && tar -xzf /tmp/${GE_PROTON_VERSION}-x86_64.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm /tmp/${GE_PROTON_VERSION}-x86_64.tar.gz \
    && rm -f /etc/machine-id /var/lib/dbus/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && dbus-uuidgen --ensure

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

USER container
ENV USER=container \
    HOME=/home/container \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
