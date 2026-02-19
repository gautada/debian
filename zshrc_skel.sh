#!/bin/zsh
# ==============================================================================
# ~/.zshrc - Zsh Configuration for Container Environments
# ==============================================================================
#
# This file is copied to /etc/skel/.zshrc during container build, making it the
# default shell configuration for all new users created in the container.
#
# FEATURES:
# - Persistent command history with duplicate filtering
# - Directory navigation shortcuts (auto-cd, directory stack)
# - Case-insensitive tab completion
# - Container-specific command aliases
# - CRT-style amber prompt with container detection
#
# DOWNSTREAM USAGE:
# - This file is automatically copied to new user home directories
# - Downstream containers can override by copying a new .zshrc to /etc/skel/
# - Users can customize their own ~/.zshrc after container creation
#
# REQUIREMENTS:
# - zsh shell (installed via Containerfile)
# - TrueColor terminal support (for prompt colors)
# - Nerd Font (optional, for container icon glyph)
#
# ==============================================================================

# ------------------------------------------------------------------------------
# HISTORY CONFIGURATION
# ------------------------------------------------------------------------------
# HISTFILE: Location of persistent history file
# HISTSIZE: Number of commands kept in memory during session
# SAVEHIST: Number of commands saved to HISTFILE
# SHARE_HISTORY: Share history across all active zsh sessions
# HIST_IGNORE_DUPS: Don't record duplicate consecutive commands
# ------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# ------------------------------------------------------------------------------
# DIRECTORY NAVIGATION
# ------------------------------------------------------------------------------
# AUTO_CD: Type directory name to cd into it (no 'cd' command needed)
# AUTO_PUSHD: Automatically push directories onto the stack for 'popd'
# ------------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD

# ------------------------------------------------------------------------------
# TAB COMPLETION
# ------------------------------------------------------------------------------
# compinit: Initialize zsh completion system
# matcher-list: Enable case-insensitive completion (lowercase matches uppercase)
# ------------------------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ------------------------------------------------------------------------------
# FALLBACK PROMPT
# ------------------------------------------------------------------------------
# Simple prompt used if the CRT prompt below fails to load
# %n = username, %m = hostname, %~ = current directory, %# = prompt char
# ------------------------------------------------------------------------------
PS1='%n@%m %~ %# '

# ------------------------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------------------------
# Standard file listing aliases
# Container utility aliases for health, version, and backup scripts
# ------------------------------------------------------------------------------
alias ll='ls -l'
alias la='ls -la'
alias l='ls -CF'
alias health='container-health'
alias version='container-version'
alias backup='container-backup'

# ==============================================================================
# CRT AMBER PROMPT - Retro Terminal Style
# ==============================================================================
#
# A two-line prompt inspired by vintage CRT terminals with amber phosphor:
#
#   Line 1: [icon] /current/path                        user@hostname
#           ^^^^^^^^^^^^^^^^^^^^^^                      ^^^^^^^^^^^^^^
#           Amber background, black text                Right-aligned, dimmed
#
#   Line 2: ❯ (or ✗ N on error)
#           ^^^^^^^^^^^^^^^^^^^
#           Green chevron on success, red X with exit code on failure
#
# FEATURES:
# - Pure zsh implementation (no external dependencies)
# - TrueColor (24-bit) color support for accurate amber hues
# - Container detection (shows container icon when running inside Docker/Podman)
# - Exit status indicator (visual feedback for command success/failure)
# - Nerd Font icon support (gracefully degrades to emoji if unavailable)
#
# COLOR PALETTE:
# - Amber background: #FFB000 (warm CRT phosphor)
# - Black text: #000000 (high contrast on amber)
# - Dim amber: #C88400 (subtle accents)
# - Success green: #7CFF6B (CRT-style green)
# - Error red: #FF4D4D (attention-grabbing)
#
# ==============================================================================

# Enable prompt variable expansion (required for dynamic prompt content)
setopt PROMPT_SUBST
autoload -Uz colors && colors

# ------------------------------------------------------------------------------
# NERD FONT ICON CONFIGURATION
# ------------------------------------------------------------------------------
# Nerd Fonts provide programming-related icons. The icon below displays in the
# prompt when running inside a container. If your terminal shows a blank box
# or "tofu" character, try one of the alternative codepoints listed below.
#
# RECOMMENDED (try in order):
#   $'\uf49e'  nf-oct-container    Octicons container icon (current default)
#   $'\uf308'  nf-linux-docker     Docker/Moby whale logo
#   $'\uf21a'  nf-fa-docker        Font Awesome docker icon
#
# ALTERNATIVES:
#   $'\uf1d3'  nf-fa-cubes         Stacked cubes (Kubernetes-ish)
#   $'\uf187'  nf-fa-archive       Archive box
#   $'\ue7b8'  nf-custom-kubernetes  Kubernetes wheel (limited font support)
#
# FALLBACK: If no Nerd Font is installed, the prompt uses 💻 emoji instead.
# ------------------------------------------------------------------------------
typeset -g ICON_CONTAINER="⬢"

# ------------------------------------------------------------------------------
# CONTAINER MODE
# ------------------------------------------------------------------------------
# Always enabled since this configuration is for container environments.
# The amber CRT prompt is designed to indicate a containerized shell.
# ------------------------------------------------------------------------------
typeset -g IN_CONTAINER=1

# ------------------------------------------------------------------------------
# CRT COLOR PALETTE (TrueColor / 24-bit)
# ------------------------------------------------------------------------------
# These colors use hex values for precise rendering in TrueColor terminals.
# %K{} sets background color, %F{} sets foreground color.
# If your terminal doesn't support TrueColor, colors may appear differently.
# ------------------------------------------------------------------------------
typeset -g CRT_BG="%K{#FFB000}"      # Amber background for line 1
typeset -g CRT_FG="%F{#000000}"      # Black text on amber background
typeset -g CRT_AMBER="%F{#FFB000}"   # Amber foreground for accents
typeset -g CRT_DIM="%F{#C88400}"     # Darker amber for subtle elements
typeset -g CRT_OK="%F{#7CFF6B}"      # Green for success indicator
typeset -g CRT_ERR="%F{#FF4D4D}"     # Red for error indicator
typeset -g CRT_RST="%f%k"            # Reset foreground and background

# ------------------------------------------------------------------------------
# RIGHT PROMPT FUNCTION
# ------------------------------------------------------------------------------
# Displays user@hostname on the right side of the terminal.
# Shows container icon prefix when running inside a container.
# Using right prompt keeps the left side stable regardless of hostname length.
# %n = username, %M = full hostname (not truncated)
# ------------------------------------------------------------------------------
function _crt_rprompt() {
  local cmark=""
  [[ -n "$IN_CONTAINER" ]] && cmark="${CRT_DIM}${ICON_CONTAINER}${CRT_RST} "
  RPROMPT="${CRT_DIM}${cmark}%n@%M${CRT_RST}"
}

# ------------------------------------------------------------------------------
# PRECMD HOOK - Runs Before Each Prompt
# ------------------------------------------------------------------------------
# This function executes before every command prompt is displayed.
# It updates both the left prompt (PROMPT) and right prompt (RPROMPT).
#
# EXIT STATUS INDICATOR:
#   >  (green) - Previous command succeeded
#   x  (red)   - Previous command failed
#
# ICON BEHAVIOR:
#   💻  - Displayed when NOT in a container (laptop emoji)
#   [container icon] - Displayed when IN a container (Nerd Font glyph)
#
# PROMPT FORMAT:
#   Line 1: [icon] /path/to/directory     (amber background, black text)
#   Line 2: ❯                             (status indicator)
# ------------------------------------------------------------------------------
function precmd() {
  local st=$?
  _crt_rprompt

  # Select icon based on container detection
  local icon="${ICON_CONTAINER}"
  [[ -z "$IN_CONTAINER" ]] && icon=">"

  # Build the two-line prompt
  # Line 1: Amber background with path
  # Line 2: Status indicator (green > on success, red x N on failure)
  #
  # The prompt is constructed with proper zsh escaping:
  # - %K{color} sets background, %F{color} sets foreground
  # - %f resets foreground, %k resets background
  # - %~ shows current directory with ~ abbreviation
  local line1="%K{#FFB000}%F{#000000} ${icon} %~ %f%k"
  local line2
  # Adds the additional space between prompt and input
  if (( st == 0 )); then
    # line2="%F{#7CFF6B}>%f "
    line2="%F{#7CFF6B}>%f   "
  else
    # line2="%F{#FF4D4D}x ${st}%f "
    line2="%F{#FF4D4D}x%f   "
  fi

  PROMPT="${line1}"
  PROMPT+=$'\n'
  PROMPT+="${line2}"
}

