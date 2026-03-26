#!/bin/sh
# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ SIGNATURE - REPOSITORY BASE SIGNATURE SCRIPT                             │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
# This script fetches the latest short commit hash from the gautada/debian
# repository on GitHub.

REPO="gautada/debian"
BRANCH="main"

# Fetch the latest commit SHA from GitHub API
SHA=$(curl -sSfL "https://api.github.com/repos/${REPO}/commits/${BRANCH}" | grep '"sha":' | head -n 1 | cut -d '"' -f 4 | cut -c1-7)

if [ -z "$SHA" ]; then
    printf "unknown\n"
    exit 1
fi

printf "%s\n" "$SHA"
