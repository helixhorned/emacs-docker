ARG BASE_IMAGE
FROM $BASE_IMAGE

LABEL maintainer="Philipp Kutin <dev@helixhorned.de>"

RUN apt update

# Install one additional locale (code from Ubuntu at Docker Hub):
RUN apt install -y locales && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN apt install -y emacs-gtk
# Documentation:
RUN apt install -y emacs-common-non-dfsg

## Set up the environment

ENV LANG=en_US.UTF-8

# Prevent warning "Couldn't connect to accessibility bus" when starting Emacs, see
#  https://bugs.launchpad.net/ubuntu/+source/at-spi2-core/+bug/1193236/comments/15
ENV NO_AT_BRIDGE=1

USER ubuntu
WORKDIR /home/ubuntu
