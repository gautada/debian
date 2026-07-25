#!/bin/sh
# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ CROND - S6 SERVICE SCRIPT                                                 │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
# This script is an s6 service run script that launches and manages the cron
# daemon (crond) within the container. It is designed to be placed at
# /etc/services.d/crond/run and executed by s6-svscan.
#
# ╭―――――――――――――――――――╮
# │ S6 OVERVIEW       │
# ╰―――――――――――――――――――╯
# s6 is a small process supervision suite that manages long-running services.
# The s6-svscan program monitors /etc/services.d/ for subdirectories, each
# representing a service. Each service directory must contain a `run` script
# that s6-supervise executes and monitors.
#
# Key s6 concepts:
# - s6-svscan: Scans a directory for services and starts s6-supervise for each
# - s6-supervise: Monitors a single service, restarting it if it exits
# - run script: Must exec into the service process (not fork/background)
#
# ╭―――――――――――――――――――╮
# │ SERVICE BEHAVIOR  │
# ╰―――――――――――――――――――╯
# This script runs crond in the FOREGROUND. This is critical because:
# 1. s6-supervise expects the run script to exec into the service
# 2. If crond daemonizes (backgrounds), s6-supervise loses track of it
# 3. Running in foreground allows s6 to properly monitor and restart crond
#
# The `-f` flag tells cron to stay in the foreground.
# The `-L 8` flag sets the log level (8 = debug, useful for troubleshooting).
#
# ╭―――――――――――――――――――╮
# │ CRON DIRECTORIES  │
# ╰―――――――――――――――――――╯
# Debian cron uses these standard directories for scheduled tasks:
#
# /etc/crontab        - System crontab file (traditional format)
# /etc/cron.d/        - Drop-in crontab fragments (package-managed)
# /etc/cron.hourly/   - Scripts run every hour
# /etc/cron.daily/    - Scripts run once daily
# /etc/cron.weekly/   - Scripts run once weekly
# /etc/cron.monthly/  - Scripts run once monthly
# /var/spool/cron/crontabs/ - Per-user crontabs (managed via `crontab` command)
#
# For this container, /etc/cron.hourly/container-backup is symlinked to
# /usr/bin/container-backup to run periodic backups.
#
# ╭―――――――――――――――――――╮
# │ TROUBLESHOOTING   │
# ╰―――――――――――――――――――╯
# If crond is not running as expected:
#
# 1. Check if the service is supervised:
#    s6-svstat /etc/services.d/crond
#
# 2. View service logs (if logging is configured):
#    Check /var/log/syslog or container stdout
#
# 3. Verify cron is installed:
#    which cron
#
# 4. Test crontab syntax:
#    crontab -l (for user crontabs)
#    cat /etc/crontab (for system crontab)
#
# 5. Restart the service manually:
#    s6-svc -r /etc/services.d/crond
#
# ╭―――――――――――――――――――╮
# │ CUSTOMIZATION     │
# ╰―――――――――――――――――――╯
# Downstream containers can customize cron behavior by:
#
# 1. Adding scripts to /etc/cron.{hourly,daily,weekly,monthly}/
# 2. Adding crontab fragments to /etc/cron.d/
# 3. Modifying /etc/crontab
# 4. Overriding this script entirely at /etc/services.d/crond/run
#
# ╭―――――――――――――――――――╮
# │ EXECUTION         │
# ╰―――――――――――――――――――╯
# The exec command replaces this shell process with cron. This is essential
# for s6 supervision - the PID that s6-supervise monitors becomes the cron
# process itself, not a shell wrapper.

exec /usr/sbin/cron -f -L 8
