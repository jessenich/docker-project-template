# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ARG ALPINE_IMAGE=alpine
ARG IMAGE_VARIANT=3.16
ARG TZ=America/New_York
ARG TAG=latest-dev
ARG REVISION_SHORT
ARG COMMIT_ID

FROM "$ALPINE_IMAGE":"$IMAGE_VARIANT" as root

ENV DISTRO=alpine
ENV VARIANT="$VARIANT"
ENV TZ="$TZ"
ENV RUNNING_IN_DOCKER=true
ENV TAG="$TAG"
ENV IS_DEVELOPMENT_IMAGE=false

USER root

COPY ./rootfs /

RUN chmod ug+wrx /usr/sbin/addsudouser.sh && \
    chmod ug+wrx /usr/sbin/entrypoint.sh

RUN apk add --update --no-cache \
    ca-certificates \
    nano \
    nano-syntax \
    rsync \
    curl \
    wget \
    tzdata \
    jq \
    yq;

FROM root as sudo

ARG USER="sysadm"
ARG GROUP=$USER
ARG UID="1000"
ARG GID="1001"
ARG HOME="/home/$USER"
ARG PASSWORD=$USER

ENV USER=$USER
ENV GROUP=$GROUP
ENV UID=$UID
ENV GID=$GID
ENV HOME=$HOME

RUN apk add --update --no-cache shadow sudo

CMD [ "/bin/ash", "/usr/sbin/addsudouser.sh", "-u", "$USER", "-g", "$GROUP", "--gid", "$GID", "--uid", "$UID", "-h", "$HOME", "-p", "$PASSWORD" ]
WORKDIR "/home/$USER"
USER "$USER"
