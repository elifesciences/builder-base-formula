#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: wait_packagist.sh PACKAGE_NAME REVISION"
    echo "Example: wait_packagist.sh elife/patterns c5e88e0422c4933a9763dd9967be4f7d63bc9cb2"
    exit 1
fi

package="$1"
revision="$2"
polling=5

while : ; do
    newest_available_revision=$(curl -v "https://packagist.org/p/${package}.json" | jq -r ".packages[\"$package\"][\"dev-master\"].source.reference")
    echo "Found revision $newest_available_revision"
    if [ "$revision" != "$newest_available_revision" ]; then
        echo "Continue waiting..."
        sleep "$polling"
    else
        echo "Stop waiting."
        break
    fi
done
