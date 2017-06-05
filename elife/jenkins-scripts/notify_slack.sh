#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: notify_slack.sh TEXT"
    echo "Example: notify_slack.sh 'Interesting text'"
    exit 1
fi

curl -v -d "{\"text\":\"$1\", \"username\":\"alfred\", \"icon_url\":\"http://ci--alfred.elifesciences.org/favicon.ico\"}" $SLACK_CHANNEL_HOOK

