# Debian Base Container

Base Debian image for downstream application containers with s6 supervision,
cron, health checks, and common operational helpers.

## Base image and build args

- Base image: `docker.io/library/debian:${IMAGE_VERSION}`
- Default `IMAGE_VERSION`: `13-slim`
- Optional build args:
  - `GIT_COMMIT` (written to `/etc/container/signature`)
  - `USER` (default `debian`)
  - `UID` (default `1001`)
  - `GID` (default `1001`)

Example build:

```bash
podman build -t debian \
  --build-arg IMAGE_VERSION=13-slim \
  --build-arg GIT_COMMIT="$(git rev-parse --short HEAD)" \
  .
```

## What this image configures

- Installs: `ca-certificates`, `curl`, `cron`, `procps`, `s6`, `sudo`,
  `tzdata`, `vim.tiny`, `zsh`
- Sets timezone to `America/New_York`
- Sets locale:
  - `LANG=C.UTF-8`
  - `LC_ALL=C.UTF-8`
- Creates mount paths:
  - `/mnt/volumes/configuration`
  - `/mnt/volumes/data`
  - `/mnt/volumes/backup`
  - `/mnt/volumes/secrets`
- Adds a `privileged` group (gid `99`) and includes the main container user
- Uses `/bin/zsh` as the default shell for the container user
- Entrypoint: `/usr/bin/s6-svscan /etc/services.d`
- Exposes `8080/tcp`

## Runtime helpers

- `/usr/bin/container-version`
  Prints `/etc/debian_version` by default.
- `/usr/bin/container-backup`
  Placeholder backup script; default output is informational only.
- `/usr/bin/container-signature`
  Prints the local build signature from `/etc/container/signature`.
- `/usr/bin/container-basesignature`
  Fetches the latest short commit from `gautada/debian` on GitHub (`main`).
- `/usr/bin/container-signaturecheck`
  Compares local and base signatures.
- `/usr/bin/container-health` and symlinks:
  - `container-liveness`
  - `container-readiness`
  - `container-startup`
  - `container-test`

## Health check behavior

The health controller currently reads executable drop-ins from:

- `/etc/health.d`

Built-in checks copied by the image:

- `/etc/health.d/osversion-check`
- `/etc/health.d/packages-check`
- `/etc/health.d/appversion-check`

To add downstream checks, copy executable scripts into `/etc/health.d/`.
Each script receives the check type (for example `liveness`, `readiness`, or
`startup`) as argument 1.

## Cron service

The image includes an s6 service at:

- `/etc/services.d/crond/run`

It runs:

- `/usr/sbin/cron -f -L 8`

An hourly job is prewired:

- `/etc/cron.hourly/container-backup` -> `/usr/bin/container-backup`

## Sudo privileges

Default sudo rules are in:

- `/etc/sudoers.d/debian`

Current defaults include `NOPASSWD` access for:

- `/usr/sbin/update-ca-certificates`
- `/usr/bin/apt update`
- targeted `apt install --yes ...` for select troubleshooting tools
  (`bind9-dnsutils`, `iputils-ping`, `nmap`, `ncat`, `git`, `jq`)

## User defaults

- Username: `debian`
- UID: `1001`
- GID: `1001`
- Shell: `/bin/zsh`
- Home: `/home/debian`
- Supplementary group: `privileged`

Build with custom user values:

```bash
podman build -t debian \
  --build-arg USER=myapp \
  --build-arg UID=1000 \
  --build-arg GID=1000 \
  .
```

## Run examples

Start container:

```bash
podman run -d --name debian debian
```

Interactive shell:

```bash
podman run --rm -it debian /bin/zsh
```

Run with standard volume mounts:

```bash
podman run -d --name debian \
  -v ./config:/mnt/volumes/configuration:ro \
  -v ./data:/mnt/volumes/data \
  -v ./backup:/mnt/volumes/backup \
  -v ./secrets:/mnt/volumes/secrets:ro \
  debian
```

Run health checks:

```bash
podman exec debian container-health
podman exec debian container-liveness
podman exec debian container-test
```

## Downstream usage notes

- Override `/usr/bin/container-backup` with app-specific backup logic.
- Override `/usr/bin/container-version` to report your app version.
- Add service directories under `/etc/services.d/<service>/run`.
- Add custom health checks under `/etc/health.d`.
- Extend sudo policy via additional files in `/etc/sudoers.d`.

## Project structure

```text
.
├── .args
├── .gitignore
├── Containerfile
├── README.md
├── etc
│   ├── health.d
│   │   ├── appversion-check
│   │   ├── osversion-check
│   │   ├── packages-check
│   │   └── signature-check
│   ├── services.d
│   │   └── crond
│   │       └── run
│   ├── skel
│   │   ├── .vimrc
│   │   └── .zshrc
│   ├── sudoers.d
│   │   └── debian
│   └── zsh
│       └── zshrc
└── usr
    └── bin
        ├── container-backup
        ├── container-basesignature
        ├── container-health
        ├── container-signature
        ├── container-signaturecheck
        └── container-version
```

## License

[Debian Free Software Guidelines
(DFSG)](https://www.debian.org/social_contract#guidelines)
