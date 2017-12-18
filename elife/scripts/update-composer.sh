#!/bin/bash
set -e

log_file="/tmp/update-composer-$(date -u +'%Y-%m-%dT%H:%M:%SZ').log"

set -o pipefail
if ! composer self-update 2>&1 | tee "$log_file"; then
    echo "Composer update failure detected."
    if grep "Connection timed out" "$log_file"; then
        echo "Retrying update..."
        composer self-update
    else
        echo "Failure does not seem retriable."
        exit 2
    fi
fi
