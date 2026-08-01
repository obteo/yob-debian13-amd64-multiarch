#!/usr/bin/env bash

set -Eeuo pipefail

cd /home/container

printf '%s\n' \
    "=================================" \
    " Container starting..." \
    "================================="

printf 'Running as UID %s GID %s\n' "$(id -u)" "$(id -g)"

if [[ -z "${STARTUP:-}" ]]; then
    echo "ERROR: STARTUP is empty or not defined." >&2
    exit 1
fi

# Convert Pterodactyl-style {{VARIABLE}} placeholders into ${VARIABLE}.
# No eval is necessary.
MODIFIED_STARTUP="$(
    printf '%s' "$STARTUP" |
        sed \
            -e 's/{{/${/g' \
            -e 's/}}/}/g'
)"

printf ':/home/container$ %s\n' "$MODIFIED_STARTUP"

# A shell is required because STARTUP is a command string.
# Quoted arguments such as "My Server" are preserved correctly.
exec /bin/bash -c "$MODIFIED_STARTUP"