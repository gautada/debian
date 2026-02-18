ARG IMAGE_NAME=debian
ARG IMAGE_VERSION=bookworm-slim
FROM docker.io/library/debian:${IMAGE_VERSION} as container

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A Debian base container."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/debian"
LABEL org.opencontainers.image.source="https://github.com/gautada/debian"
LABEL org.opencontainers.image.version="${CONTAINER_VERSION}"
LABEL org.opencontainers.image.license="Debian Free Software Guidelines (DFSG)"

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
# This package section installs the base packges to make the the container 
# have the base capabilities across all containers.  This section should
# install and then clean the package management system.
#
# bind9-dnsutils - To debug dns issues
# ca-sertificate - Needed to support all manor of SSL stuff
# curl - To fetch remote files and test http(s) endpoint
# cron - Scheduler
# iputils-ping - Ping utlity
# nmap - Network debug
# ncat - More network debug
# procps - Utilities for system information
# git - Fetch project files etc
# jq - Parsing JSON
# s6 - Control container processes
# sudo - Priviledged permissions
# tzdata - Timezone data
# vim.tiny - Standard editor
# zsh - Standardized shell
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
            # bind9-dnsutils \
            ca-certificates \
            curl \
            cron \
            # iputils-ping \
            # nmap \
            # ncat \
            procps \
            # git \
            # jq \
            s6 \
            sudo \
            tzdata \
            vim.tiny \
            zsh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ╭―――――――――――――――――――╮
# │ TIMEZONE          │
# ╰―――――――――――――――――――╯
# Set the timezone to east coast us so logs and interaction do not need to be
# time shifted.
RUN /bin/mkdir -p /etc/container \
 && echo "America/New_York" > /etc/timezone \
 && /bin/ln -fsv "/usr/share/zoneinfo/$(cat /etc/timezone)" /etc/localtime

# ╭――――――――――――――――――――╮
# │ VOLUMES            │
# ╰――――――――――――――――――――╯
# The volumes section creates the mount points for the most common volume
# mounts.  Configuration is for mounting configmaps, Data is for any runtime
# data that needed to persist across container restarts.  Backup is for local
# backup functions to have a local cahce.  Secrets provides a mount point for
# secret files to be accessible.
RUN /bin/mkdir -p /mnt/volumes/configuration \
                  /mnt/volumes/data \ 
                  /mnt/volumes/backup \
                  /mnt/volumes/secrets
 
# ╭―――――――――――――――――――╮
# │ BACKUP            │
# ╰―――――――――――――――――――╯
COPY backup.sh /usr/bin/container-backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
RUN mkdir -p /etc/services.d
# COPY crond.sh /etc/services.d/crond/run

# ╭――――――――――――――――――――╮
# │ PRIVILEGE          │
# ╰――――――――――――――――――――╯
# Privileges provides a mechanism for least privilege.  This capability takes
# a priviliges file into a drop-in folder.  A privileges files is in a sudoers
# file format.  This defines what explicit commands can be run by the
# privileged user group.  
COPY privileges /etc/sudoers.d/debian
RUN /usr/sbin/groupadd --gid 99 privileged

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
# The Version capability provides an easy way for getting the version of the
# software within the container.  This is usuallly used in the CICD process to
# confirm the intended version is the version that was built.  The version file
# is just a script that returns ONLY the version of the software running.
COPY version.sh /usr/bin/container-version

# ╭――――――――――――――――――――╮
# │ HEALTH             │
# ╰――――――――――――――――――――╯
# The health mechanism uses the the health.d drop-in to hold scripts that test
# the container's health.  This mechanism support individual container
# controllers to support liveness, readiness, and startup. This mechanism also
# supports a test feature that is used in the CICD process to make sure the
# container is working.  This means that the container should be able to run
# independently of the environment and configuration it is intended to run
# within. For downstream containers just define a health script and put in the
# /etc/container/health.d/ drop-in folder.
COPY health.sh /usr/bin/container-health
RUN /bin/mkdir -p /etc/container/health.d \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-liveness \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-readiness \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-startup \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-test

# ╭――――――――――――――――――――╮
# │ ZSH                │
# ╰――――――――――――――――――――╯
# Configure zsh with system-wide and user skeleton configurations.
# The /etc/zsh/zshrc provides system-wide defaults.
# The /etc/skel/.zshrc is copied to user home on creation via useradd --create-home.
RUN /bin/mkdir -p /etc/zsh
COPY zshrc_etc.sh /etc/zsh/zshrc
COPY zshrc_skel.sh /etc/skel/.zshrc

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
# The user configuration defines the main container user account.  Downstream
# containers will modify the user to be a name that is reasonable for the
# image/container's purpose.  This user will be given privileges using the
# privileged group and the default shell will be setup.  As well as ownership
# of volume mount folders.
ARG USER=debian
ARG UID=1001
ARG GID=1001
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN /usr/sbin/groupadd --gid $UID $USER \
 && /usr/sbin/useradd --create-home --gid $GID --shell /bin/zsh \
                      --uid $UID $USER \
 && /usr/sbin/usermod -aG privileged $USER \
 && echo "$USER:$USER" | /usr/sbin/chpasswd \
 && /bin/chown -R $USER:$USER /mnt/volumes/backup \
 && /bin/chown -R $USER:$USER /mnt/volumes/configuration \
 && /bin/chown -R $USER:$USER /mnt/volumes/data \
 && /bin/chown -R $USER:$USER /mnt/volumes/secrets

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
ENTRYPOINT [ "/usr/bin/s6-svscan" , "/etc/services.d" ]
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configuration
VOLUME /mnt/volumes/data
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /
