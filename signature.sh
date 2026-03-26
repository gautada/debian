#!/bin/sh
# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ SIGNATURE - CONTAINER SIGNATURE SCRIPT                                    │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
# This script returns the build signature of the container.

SIGNATURE_FILE="/etc/container/signature"

if [ ! -f "$SIGNATURE_FILE" ]; then
    printf "unknown\n"
    exit 1
fi

cat "$SIGNATURE_FILE"
