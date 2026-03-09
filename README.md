# Debian Base Container

> Hardened Debian (Trixie/13) distilled into a repeatable base image for
> every downstream Eureka FARMS workload.

| Item | Details |
| --- | --- |
| Owner | Adam Gautier (@gautada) |
| Registry | `gautada/debian` |
| Status | **Active** |
| Purpose | Provide a secure Debian base with consistent backup, health, privilege, and init scaffolding for child containers. |

A minimal [Debian](https://www.debian.org) base container image designed
for building downstream application containers. Built on `debian:trixie-slim`
(Debian 13), this image prioritizes small size while providing essential
infrastructure for container operations.

## Purpose

This container serves as the foundation for other containers, providing:

- **Minimal footprint** - Uses `trixie-slim` base with only essential packages.
- **Least privilege security** - Sudoers-based permission model for specific
  commands.
- **Health monitoring** - Drop-in health check system for liveness, readiness,
  and startup probes.
- **Version detection** - Standardized mechanism to query container and OS
  versions.
- **Backup infrastructure** - Placeholder backup system for downstream
  implementation.
- **Process supervision** - Uses s6-overlay for managing container services.

## Architecture

```text
+---------------------------+
| Downstream container      |
|  (inherits FROM this)     |
|    Custom services        |
+-------------+-------------+
              ^
              |
+-------------+-------------+
| gautada/debian base image |
|  • s6-svscan init + cron  |
|  • Health + backup hooks  |
|  • Privilege scaffolding  |
|  • Locale/volume setup    |
+-------------+-------------+
              ^
              |
+-------------+-------------+
| debian:trixie-slim        |
+---------------------------+
```

## Features

### Locale

The container sets UTF-8 locale to prevent terminal and application encoding
issues:

```text
LANG=C.UTF-8
LC_ALL=C.UTF-8
```

### Volumes

Standard volume mount points are created for consistent data management:

| Path | Purpose |
| --- | --- |
| `/mnt/volumes/configuration` | ConfigMaps and configuration files |
| `/mnt/volumes/data` | Runtime data persisted across restarts |
| `/mnt/volumes/backup` | Local backup cache |
| `/mnt/volumes/secrets` | Secret files and credentials |

### Least Privilege Model

The container implements a least privilege security model using sudoers:

- A `privileged` group (GID 99) is created.
- The container user is added to this group.
- Specific commands are whitelisted in `/etc/sudoers.d/debian`.

**Whitelisted commands:**

- `/usr/sbin/cron`
- `/usr/sbin/update-ca-certificates`
- `/etc/cron.hourly/container-backup`

### Health Monitoring

A drop-in health check system supports Kubernetes-style probes via
`/usr/bin/container-health`.

**Standard Probes:**

- `/usr/bin/container-liveness`
- `/usr/bin/container-readiness`
- `/usr/bin/container-startup`
- `/usr/bin/container-test` (for CI/CD validation)

**Built-in Checks:**

- `osversion-check` — verifies the running OS version matches upstream.
- `packages-check` — verifies installed packages are up to date.

### Standard Scripts

| Script | Container Path | Description |
| --- | --- | --- |
| `version.sh` | `/usr/bin/container-version` | Returns the software/OS version. |
| `backup.sh` | `/usr/bin/container-backup` | Placeholder for backup logic; runs hourly via cron. |
| `crond.sh` | `/etc/services.d/crond/run` | s6 service runner for the cron daemon. |
| `health.sh` | `/usr/bin/container-health` | Controller for the health drop-in system. |
| `osversion-check.sh` | `/etc/container/health.d/osversion-check` | Health probe that checks Debian release. |
| `packages.sh` | `/etc/container/health.d/packages-check` | Health probe that checks for pending updates. |

### Process Supervision (s6-overlay)

This container uses [s6-overlay](https://github.com/just-containers/s6-overlay)
as its init system (PID 1).

- **Supervisor:** `s6-svscan` monitors `/etc/services.d`.
- **Services:** Each service is a directory in `/etc/services.d` containing a
  `run` script.
- **Lifecycle:** s6 handles clean shutdowns and automatic service restarts.

### Shell & Editor Configuration

- **Shell:** Zsh is the default shell. System-wide configuration is at
  `/etc/zsh/zshrc`.
- **Skeleton:** New users inherit a baseline `.zshrc` and `.vimrc` from
  `/etc/skel`.
- **Editor:** `vim.tiny` is configured as the default editor.

## Build & Run

### Build

```bash
podman build -t gautada/debian:latest .
```

### Run

```bash
# Standard interactive shell
podman run -it --rm gautada/debian:latest /bin/zsh

# Run as a background service
podman run -d --name my-debian gautada/debian:latest
```

## Operations Playbook

| Scenario | Command |
| --- | --- |
| Check Health | `podman exec my-debian container-health` |
| Check Version | `podman exec my-debian container-version` |
| Manual Backup | `podman exec my-debian container-backup` |

## License

[Debian Free Software Guidelines (DFSG)](https://www.debian.org/social_contract#guidelines)
