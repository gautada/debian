#!/bin/sh
# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ SIGNATURE - SIGNATURE CHECK SCRIPT                                       │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
# This script compares the local build signature with the latest repository
# base signature and returns success or failure.

LOCAL_SIG=$(/usr/bin/container-signature)
BASE_SIG=$(/usr/bin/container-basesignature)

printf "Local Signature:  %s\n" "$LOCAL_SIG"
printf "Base Signature:   %s\n" "$BASE_SIG"

if [ "$LOCAL_SIG" = "unknown" ] || [ "$BASE_SIG" = "unknown" ]; then
    printf "One or both signatures are unknown. Cannot verify.\n"
    exit 1
fi

if [ "$LOCAL_SIG" = "$BASE_SIG" ]; then
    printf "Signatures match. Success.\n"
    exit 0
else
    printf "Signatures do not match. Failure.\n"
    exit 1
fi
