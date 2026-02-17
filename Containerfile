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
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ VOLUMES            │
# ╰――――――――――――――――――――╯
RUN /bin/mkdir -p /mnt/volumes/configmaps /mnt/volumes/data \ 
    /mnt/volumes/backup /mnt/volumes/secrets  
                  
# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    bind9-dnsutils ca-certificates curl iputils-ping \
    nmap ncat git jq nano s6 sudo tzdata zsh procps cron \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ╭―――――――――――――――――――╮
# │ CONFIG (ROOT)     │
# ╰―――――――――――――――――――╯
RUN /bin/mkdir -p /etc/container \
 && echo "America/New_York" > /etc/timezone \
 && /bin/ln -fsv "/usr/share/zoneinfo/$(cat /etc/timezone)" /etc/localtime
 
# ╭―――――――――――――――――――╮
# │ BACKUP            │
# ╰―――――――――――――――――――╯
# COPY container-backup /usr/bin/container-backup
RUN /bin/ln -fsv /usr/bin/container-backup /etc/cron.hourly/container-backup
COPY backup.sh /etc/container/backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
# COPY container-entrypoint.sh /usr/bin/container-entrypoint
# COPY entrypoint.sh /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ INIT               │
# ╰――――――――――――――――――――╯
RUN mkdir -p /etc/services.d
# COPY container-init /etc/services.d/container/run

# ╭――――――――――――――――――――╮
# │ PRIVILEGE          │
# ╰――――――――――――――――――――╯
COPY privileges /etc/container/privileges
RUN /bin/ln -fsv /etc/container/privileges /etc/sudoers.d/privileges \
 && /usr/sbin/groupadd --gid 99 privileged

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
COPY container-version.sh /usr/bin/container-version

# ╭――――――――――――――――――――╮
# │ HEALTH             │
# ╰――――――――――――――――――――╯
# COPY container-health /usr/bin/container-health
# COPY health /etc/container/health
RUN /bin/mkdir -p /etc/container/health.d \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-liveness \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-readiness \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-startup \
 && /bin/ln -fsv /usr/bin/container-health /usr/bin/container-test
# COPY cron.health /etc/container/health.d/cron.health
# COPY os.test /etc/container/health.d/os.test

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=debian
ARG UID=1001
ARG GID=1001
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# ENTRYPOINT ["/usr/bin/container-entrypoint"]
RUN /usr/sbin/groupadd --gid $UID $USER \
 && /usr/sbin/useradd --create-home --gid $GID --shell /bin/zsh \
 --uid $UID $USER \
 && /usr/sbin/usermod -aG privileged $USER \
#  && /usr/sbin/chpasswd << "$USER:$USER" \
 && echo "$USER:$USER" | /usr/sbin/chpasswd \
 && /bin/chown -R $USER:$USER /mnt/volumes/data \
 && /bin/chown -R $USER:$USER /mnt/volumes/backup \
 && /bin/chown -R $USER:$USER /mnt/volumes/configmaps \
 && /bin/chown -R $USER:$USER /mnt/volumes/secrets

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
FROM scratch
COPY --from=container / /
# ENTRYPOINT ["/usr/bin/container-entrypoint"]
# ENTRYPOINT ["zsh"]
ENTRYPOINT [ "/usr/bin/s6-svscan" , "/etc/services.d" ]
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/data
VOLUME /mnt/volumes/secrets
# VOLUME /mnt/volumes/secrets/namespace
# VOLUME /mnt/volumes/secrets/container
# EXPOSE 8080/tcp
# USER root
WORKDIR /
