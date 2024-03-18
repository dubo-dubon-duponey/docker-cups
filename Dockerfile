ARG           FROM_REGISTRY=docker.io/dubodubonduponey

ARG           FROM_IMAGE_RUNTIME=base:runtime-bookworm-2024-03-01
ARG           FROM_IMAGE_TOOLS=tools:linux-bookworm-2024-03-01

FROM          $FROM_REGISTRY/$FROM_IMAGE_TOOLS                                                                          AS builder-tools

#######################
# Running image
#######################
FROM          $FROM_REGISTRY/$FROM_IMAGE_RUNTIME

# hadolint ignore=DL3002
USER          root

# Avahi and cups
RUN           --mount=type=secret,uid=100,id=CA \
              --mount=type=secret,uid=100,id=CERTIFICATE \
              --mount=type=secret,uid=100,id=KEY \
              --mount=type=secret,uid=100,id=GPG.gpg \
              --mount=type=secret,id=NETRC \
              --mount=type=secret,id=APT_SOURCES \
              --mount=type=secret,id=APT_CONFIG \
              apt-get update -qq && \
              apt-get install -qq --no-install-recommends \
                dbus=1.14.10-1~deb12u1 \
                avahi-daemon=0.8-10 \
                cups=2.4.2-3+deb12u5 && \
              apt-get -qq autoremove      && \
              apt-get -qq clean           && \
              rm -rf /var/lib/apt/lists/* && \
              rm -rf /tmp/*               && \
              rm -rf /var/tmp/*

# Drivers
RUN           --mount=type=secret,uid=100,id=CA \
              --mount=type=secret,uid=100,id=CERTIFICATE \
              --mount=type=secret,uid=100,id=KEY \
              --mount=type=secret,uid=100,id=GPG.gpg \
              --mount=type=secret,id=NETRC \
              --mount=type=secret,id=APT_SOURCES \
              --mount=type=secret,id=APT_CONFIG \
              apt-get update -qq && \
              apt-get install -qq --no-install-recommends \
                printer-driver-brlaser=6-3 && \
              apt-get -qq autoremove      && \
              apt-get -qq clean           && \
              rm -rf /var/lib/apt/lists/* && \
              rm -rf /tmp/*               && \
              rm -rf /var/tmp/*

# Deviate avahi temporary files into /tmp (there is a socket, so, probably need exec)
RUN           mkdir -p "$XDG_RUNTIME_DIR"/avahi-daemon; ln -s "$XDG_RUNTIME_DIR"/avahi-daemon /run; chown avahi:avahi /run/avahi-daemon; chmod 777 /run/avahi-daemon

USER          dubo-dubon-duponey

EXPOSE        663

# Cups will add printers there with cupsctl
VOLUME        /etc/cups

# Used by dbus and avahi (see entrypoint.sh)
# /tmp/runtime by default - cannot be configured since build time makes use of it
VOLUME        "$XDG_RUNTIME_DIR"

