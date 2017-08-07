#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
owner_and_repo=$("$DIR/github_owner_and_repo.sh")

if [ -z $commit ]
then
    commit=$(git rev-parse HEAD)
fi

status_code=$(curl \
    -v \
    -s \
    -o github_commit_status.log \
    -w '%{http_code}' \
    "https://api.github.com/repos/$owner_and_repo/statuses/$commit?access_token=$GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"state\": \"$status\", \"description\": \"$description\", \"context\": \"$context\", \"target_url\": \"$BUILD_URL\"}")

if [[ $status_code -eq 201 ]]; then
    rm github_commit_status.log
    exit 0
fi

cat github_commit_status.log
rm github_commit_status.log
exit 22 # standard curl -f exit code
