#!/bin/zsh
# ==============================================================================
# /etc/zsh/zshrc - System-Wide Zsh Configuration
# ==============================================================================
#
# This file is sourced for ALL interactive zsh shells on the system, regardless
# of user. It runs BEFORE the user's personal ~/.zshrc file.
#
# LOCATION: /etc/zsh/zshrc (Debian/Ubuntu standard path)
#
# LOAD ORDER FOR INTERACTIVE SHELLS:
#   1. /etc/zsh/zshenv     (all shells, first)
#   2. /etc/zsh/zprofile   (login shells only)
#   3. /etc/zsh/zshrc      (interactive shells - THIS FILE)
#   4. ~/.zshrc            (user's personal config)
#   5. /etc/zsh/zlogin     (login shells, after .zshrc)
#
# PURPOSE:
# - Set system-wide environment variables for all container users
# - Establish baseline PATH configuration
# - Mark the environment as a container for scripts that need to detect this
#
# DOWNSTREAM USAGE:
# - Downstream containers can append to this file or replace it entirely
# - User ~/.zshrc settings take precedence (loaded after this file)
# - Avoid setting user-specific preferences here; use /etc/skel/.zshrc instead
#
# NOTE: This file should only contain settings that apply to ALL users.
# User-specific settings belong in /etc/skel/.zshrc (copied to new user homes)
# or in individual ~/.zshrc files.
#
# ==============================================================================

# ------------------------------------------------------------------------------
# DEFAULT EDITOR
# ------------------------------------------------------------------------------
# Sets the system-wide default text editor for commands like `git commit`,
# `crontab -e`, `visudo`, etc. Users can override in their ~/.zshrc.
#
# Common alternatives:
#   vim     - Vi Improved (current default, requires vim-tiny or vim package)
#   nano    - Beginner-friendly editor (requires nano package)
#   vi      - Basic vi (always available on Debian)
# ------------------------------------------------------------------------------
export EDITOR=vim

# ------------------------------------------------------------------------------
# CONTAINER ENVIRONMENT FLAG
# ------------------------------------------------------------------------------
# Signals to scripts and applications that they are running inside a container.
# This can be used to:
#   - Skip hardware-specific operations
#   - Adjust logging behavior
#   - Modify service startup sequences
#   - Enable/disable features based on container context
#
# Usage in scripts:
#   if [[ "$CONTAINER" == "true" ]]; then
#     echo "Running in container"
#   fi
# ------------------------------------------------------------------------------
export CONTAINER=true

# ------------------------------------------------------------------------------
# PATH CONFIGURATION
# ------------------------------------------------------------------------------
# Ensures standard binary directories are in PATH for all users.
# Prepends standard locations to handle cases where PATH might be minimal.
#
# Directory purposes:
#   /usr/local/bin  - Locally compiled/installed software (highest priority)
#   /usr/bin        - Distribution-provided user commands
#   /bin            - Essential system commands
#
# Note: $PATH at end preserves any existing PATH entries (e.g., from parent
# shell or container runtime).
# ------------------------------------------------------------------------------
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
