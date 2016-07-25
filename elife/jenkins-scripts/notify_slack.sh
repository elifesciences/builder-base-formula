#!/bin/bash
set -e

curl -v -d "{\"text\":\"$1\", \"username\":\"alfred\", \"icon_url\":\"http://ci--alfred.elifesciences.org/favicon.ico\"}" $SLACK_CHANNEL_HOOK

