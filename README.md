# Debian Base Container

A minimal [Debian](https://www.debian.org) base container image designed for building
downstream application containers. Built on `debian:bookworm-slim`, this image
prioritizes small size while providing essential infrastructure for container
operations.

## Purpose

This container serves as the foundation for other containers, providing:

- **Minimal footprint** - Uses `bookworm-slim` base with only essential packages
- **Least privilege security** - Sudoers-based permission model for specific commands
- **Health monitoring** - Drop-in health check system for liveness, readiness,
  and startup probes
- **Version detection** - Standardized mechanism to query container software
  versions
- **Backup infrastructure** - Placeholder backup system for downstream implementation
- **Process supervision** - Uses s6 for managing container services

## Features

### Locale

The container sets UTF-8 locale to prevent terminal and application encoding issues:

```
LANG=C.UTF-8
LC_ALL=C.UTF-8
```

`C.UTF-8` is a built-in glibc locale — no additional packages required.

### Volumes

Four standard volume mount points are created for consistent data management:

| Path                         | Purpose                                |
| ---------------------------- | -------------------------------------- |
| `/mnt/volumes/configuration` | ConfigMaps and configuration files     |
| `/mnt/volumes/data`          | Runtime data persisted across restarts |
| `/mnt/volumes/backup`        | Local backup cache                     |
| `/mnt/volumes/secrets`       | Secret files and credentials           |

### Least Privilege Model

The container implements a least privilege security model using sudoers:

- A `privileged` group (GID 99) is created
- The container user is added to this group
- Specific commands are whitelisted in `/etc/sudoers.d/debian`
- Downstream containers can extend the privileges file

**Default allowed commands:**

- `/usr/sbin/cron` - Start the cron daemon
- `/usr/sbin/update-ca-certificates` - Update SSL certificates
- `/etc/cron.hourly/container-backup` - Run backup script

### Health Monitoring

A drop-in health check system supports Kubernetes-style probes:

```
/usr/bin/container-health     # Main health script
/usr/bin/container-liveness   # Symlink for liveness probes
/usr/bin/container-readiness  # Symlink for readiness probes
/usr/bin/container-startup    # Symlink for startup probes
/usr/bin/container-test       # Symlink for CI/CD testing
```

**Built-in health checks:**

- `osversion-check` — verifies the OS version is as expected; installed at
  `/etc/container/health.d/osversion-check`

**Adding health checks (downstream):**

Place executable scripts in `/etc/container/health.d/`. Each script receives
the probe type as an argument (`health`, `liveness`, `readiness`, `startup`,
or `test`).

```bash
#!/bin/sh
# /etc/container/health.d/myapp.health
case "$1" in
  liveness)  curl -sf http://localhost:8080/health ;;
  readiness) curl -sf http://localhost:8080/ready ;;
  *)         exit 0 ;;
esac
```

### Version Detection

The `/usr/bin/container-version` script outputs the software version.
Downstream containers should override this script to return their application
version.

```bash
container-version
# Output: 13.3  (Debian version by default)
```

### Backup System

The `/usr/bin/container-backup` script is a placeholder for downstream backup
implementations. Override this script to implement application-specific backup
logic.

### Process Supervision

Uses [s6](https://skarnet.org/software/s6/) as the init system and process
supervisor:

- Services are defined in `/etc/services.d/`
- Each service has a `run` script
- s6 handles process lifecycle and restarts

**Built-in services:**

- **crond** (`crond.sh`) — runs `/usr/sbin/cron` under s6 supervision, enabling
  scheduled tasks via standard cron. An hourly `container-backup` job is
  pre-configured.

### ZSH Configuration

ZSH is the default shell for all container users. Two configuration files are
provided:

- `zshrc_etc.sh` → `/etc/zsh/zshrc` — system-wide ZSH defaults applied to all users
- `zshrc_skel.sh` → `/etc/skel/.zshrc` — skeleton file copied to new user home
  directories on creation

### VIM Configuration

A default `vimrc` is included and placed at `/etc/skel/.vimrc` so all users
created with `--create-home` automatically inherit it.

## Installed Packages

**Included:**

- `ca-certificates` - SSL/TLS certificate authorities
- `curl` - HTTP client for fetching files and testing endpoints
- `cron` - Task scheduler
- `procps` - Process utilities (ps, top, etc.)
- `s6` - Process supervisor
- `sudo` - Privilege escalation
- `tzdata` - Timezone data
- `vim.tiny` - Lightweight text editor
- `zsh` - Default shell

## User Configuration

| Setting  | Default Value          |
| -------- | ---------------------- |
| Username | `debian`               |
| UID      | `1001`                 |
| GID      | `1001`                 |
| Shell    | `/bin/zsh`             |
| Home     | `/home/debian`         |
| Groups   | `debian`, `privileged` |

Downstream containers can override these via build arguments:

```bash
podman build --build-arg USER=myapp --build-arg UID=1000 --build-arg GID=1000 .
```

## Build

### Prerequisites

- Podman or Docker
- Git (for cloning)

### Build Commands

```bash
# Standard build
podman build -t debian .

# Build without cache
podman build --no-cache -t debian .

# Build with custom user
podman build --build-arg USER=myapp -t debian .
```

## Run

### Basic Usage

```bash
# Run container
podman run -d --name debian debian

# Run with interactive shell
podman run -it --rm debian /bin/zsh

# Execute shell in running container
podman exec -it --user 1001 debian /bin/zsh
```

### With Volumes

```bash
podman run -d --name debian \
  -v ./config:/mnt/volumes/configuration:ro \
  -v ./data:/mnt/volumes/data \
  -v ./backup:/mnt/volumes/backup \
  -v ./secrets:/mnt/volumes/secrets:ro \
  debian
```

### Health Checks

```bash
# Check container health
podman exec debian container-health

# Check liveness
podman exec debian container-liveness

# Run tests (for CI/CD)
podman exec debian container-test
```

## Building Downstream Containers

Use this image as your base:

```dockerfile
FROM gautada/debian:latest

# Override user if needed
ARG USER=myapp
RUN usermod -l $USER debian \
 && groupmod -n $USER debian \
 && mv /home/debian /home/$USER \
 && usermod -d /home/$USER $USER

# Add your application
COPY myapp /usr/bin/myapp

# Add health check
COPY myapp.health /etc/container/health.d/myapp.health
RUN chmod +x /etc/container/health.d/myapp.health

# Override version script
COPY version.sh /usr/bin/container-version

# Add service
COPY myapp-run.sh /etc/services.d/myapp/run

# Extend privileges if needed
COPY privileges /etc/sudoers.d/myapp
```

## Configuration

### Timezone

Default timezone is `America/New_York`. To change, modify `/etc/timezone`
and update the symlink:

```dockerfile
RUN echo "UTC" > /etc/timezone \
 && ln -fsv /usr/share/zoneinfo/UTC /etc/localtime
```

### Exposed Ports

- `8080/tcp` - Default application port (customize in downstream)

## Project Structure

```
.
├── .args                    # Build arguments
├── .gitignore               # Git ignore rules
├── .hadolint.yaml           # Hadolint Dockerfile linter configuration
├── .markdownlint.yaml       # Markdown linter configuration
├── .pre-commit-config.yaml  # Pre-commit hook configuration
├── .shellcheckrc            # ShellCheck configuration
├── .yamllint.yaml           # YAML linter configuration
├── Containerfile            # Container build definition
├── README.md                # This file
├── backup.sh                # Backup placeholder script
├── crond.sh                 # s6 cron service runner
├── health.sh                # Health check controller
├── osversion-check.sh       # Built-in OS version health check
├── privileges               # Sudoers configuration
├── version.sh               # Version detection script
├── vimrc                    # Default VIM configuration
├── zshrc_etc.sh             # System-wide ZSH configuration
└── zshrc_skel.sh            # User skeleton ZSH configuration
```

## License

[Debian Free Software Guidelines (DFSG)](https://www.debian.org/social_contract#guidelines)

## Links

- [Docker Hub](https://hub.docker.com/r/gautada/debian)
- [GitHub](https://github.com/gautada/debian)
- [Debian Project](https://www.debian.org)
