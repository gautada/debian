# Debian Base Container

Base Debian image for downstream application containers with s6 supervision,
health checks, and common operational helpers.

## Base image and build args

- Base image: `docker.io/library/debian:${IMAGE_VERSION}`
- Default `IMAGE_VERSION`: `13-slim`
- Optional build args:
  - `GIT_COMMIT` (written to `/etc/container/signature`)
  - `USER` (default `debian`)
  - `UID` (default `1000`)
  - `GID` (default `1000`)

Example build:

```bash
podman build -t debian \
  --build-arg IMAGE_VERSION=13-slim \
  --build-arg GIT_COMMIT="$(git rev-parse --short HEAD)" \
  .
```

## What this image configures

- Installs: `ca-certificates`, `curl`, `procps`, `s6`, `sudo`,
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
- Runs as `USER debian` (non-root)
- Exposes `8080/tcp`

## s6 process supervision

### Architecture

This image uses [s6](https://skarnet.org/software/s6/) as the container init
system. s6-svscan runs as PID 1 and supervises all services defined under
`/etc/services.d`.

Process tree at runtime:

```text
PID 1: s6-svscan /etc/services.d    [debian]
  |
  +-- s6-supervise idle              [debian]
  |     |
  |     +-- sleep infinity           [debian]
  |
  +-- s6-supervise <app-service>     [debian]
        |
        +-- application              [debian]
```

The container runs as `USER debian`. All services run under the debian user.

### Service directory convention

Each service lives in its own directory under `/etc/services.d/`:

```text
/etc/services.d/
  <service-name>/
    run              # required: executable that execs into the service
    finish           # optional: runs after the service exits
    down             # optional: if present, service is not started automatically
```

The `run` script must:

1. Be executable (`chmod +x`).
2. Use `exec` to replace the shell with the service process.
3. Run the service in the foreground (no daemonizing).

### Supervision state

s6 creates runtime state directories automatically:

- `/etc/services.d/<service>/supervise/` — per-service control and status
- `/etc/services.d/.s6-svscan/` — scanner-level control directory

These directories are created at runtime and should not be committed to the
repository or copied into images.

### Adding services in downstream images

To add a service in a downstream Containerfile:

```dockerfile
COPY etc/services.d/myapp/run /etc/services.d/myapp/run
RUN chmod +x /etc/services.d/myapp/run
```

Example `run` script:

```sh
#!/bin/sh
exec /usr/bin/myapp --foreground
```

### Runtime service management

Check service status:

```bash
s6-svstat /etc/services.d/idle
```

Restart a service (stop then start):

```bash
s6-svc -r /etc/services.d/idle
```

Stop a service:

```bash
s6-svc -d /etc/services.d/idle
```

Start a stopped service:

```bash
s6-svc -u /etc/services.d/idle
```

Send a signal to a service (e.g., SIGHUP):

```bash
s6-svc -h /etc/services.d/idle
```

These commands work from inside the container via `podman exec` or
`kubectl exec`. The container continues running when individual services are
stopped or restarted.

### Crash recovery

s6-supervise automatically restarts a service if it exits unexpectedly. This
provides automatic crash recovery without container restart.

To prevent automatic restart (e.g., for one-shot tasks), create a `down` file
in the service directory:

```bash
touch /etc/services.d/myapp/down
```

Remove it and bring the service up:

```bash
rm /etc/services.d/myapp/down
s6-svc -u /etc/services.d/myapp
```

### Signal handling and shutdown

When the container receives SIGTERM (e.g., from `podman stop` or Kubernetes
pod termination):

1. s6-svscan receives SIGTERM.
2. s6-svscan sends SIGTERM to each s6-supervise process.
3. Each s6-supervise sends SIGTERM to its supervised service.
4. Services that handle SIGTERM exit cleanly.
5. After services exit (or the grace period expires), s6-svscan exits.

Test shutdown behavior:

```bash
podman stop --time 30 <container>
```

If a service ignores SIGTERM, it will be killed by SIGKILL after the grace
period. Services that need cleanup should handle SIGTERM or provide a `finish`
script.

The `.s6-svscan/finish` script (if present) runs after all services have been
brought down. Use it for final cleanup.

### Kubernetes integration

The Containerfile sets `USER debian`, so the container runs as non-root by
default. s6-svscan runs as the debian user (UID 1000).

Recommended pod `securityContext`:

```yaml
spec:
  containers:
    - name: myapp
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        runAsNonRoot: true
        allowPrivilegeEscalation: false
```

For volume mounts, ensure the volume permissions are compatible with UID 1000
or use `fsGroup: 1000` in the pod security context.

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

## Idle service

The image includes a default s6 service at:

- `/etc/services.d/idle/run`

It runs `sleep infinity` to keep s6-svscan alive without requiring any daemon
or root privileges. Downstream containers add their own services under
`/etc/services.d/`.

## Sudo privileges

Default sudo rules are in:

- `/etc/sudoers.d/debian`

Current defaults include `NOPASSWD` access for:

- `/usr/sbin/update-ca-certificates`
- `/usr/bin/apt update`
- targeted `apt install --yes ...` for select troubleshooting tools
  (`bind9-dnsutils`, `iputils-ping`, `nmap`, `ncat`, `git`, `jq`)

Note: sudo requires `allowPrivilegeEscalation: true` in the Kubernetes
security context. When running with `allowPrivilegeEscalation: false`, sudo
commands will not work.

## User defaults

- Username: `debian`
- UID: `1000`
- GID: `1000`
- Shell: `/bin/zsh`
- Home: `/home/debian`
- Supplementary groups: `privileged`, `uucp`

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
│   │   └── idle
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
