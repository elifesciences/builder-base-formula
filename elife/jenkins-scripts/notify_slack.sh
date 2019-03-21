#!/bin/bash
set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: notify_slack.sh TEXT [CHANNEL]"
    echo "Example: notify_slack.sh 'Interesting text' '#deployments'"
    exit 1
fi

text="$1"
channel="${2:-#deployments}"

curl -v -d "{\"text\":\"${text}\", \"channel\":\"${channel}\", \"username\":\"alfred\", \"icon_url\":\"https://alfred.elifesciences.org/favicon.ico\"}" "$SLACK_CHANNEL_HOOK"

