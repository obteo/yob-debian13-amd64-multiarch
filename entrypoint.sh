#!/usr/bin/env bash

set -Eeuo pipefail

cd /home/container

printf '%s\n' \
    '=================================' \
    ' Container starting...' \
    '================================='

printf 'Running as UID %s GID %s\n' "$(id -u)" "$(id -g)"

if [[ -z "${STARTUP:-}" ]]; then
    printf 'ERROR: STARTUP is empty or not defined.\n' >&2
    exit 1
fi

# Convert Pterodactyl placeholders such as {{SERVER_PORT}} to ${SERVER_PORT}.
# The resulting command is executed by Bash so quoted values and shell syntax
# are preserved, unlike the old unquoted "exec ${MODIFIED_STARTUP}" method.
MODIFIED_STARTUP="$(
    printf '%s' "$STARTUP" |
        sed \
            -e 's/{{/${/g' \
            -e 's/}}/}/g'
)"

printf ':/home/container$ %s\n' "$MODIFIED_STARTUP"

# Replace the entrypoint process with the configured startup command.
exec /bin/bash -c "$MODIFIED_STARTUP"
