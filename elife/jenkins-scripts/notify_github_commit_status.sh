#!/bin/bash
set -e

owner_and_repo=$(git remote -v 2>&1 | grep fetch | sed -e 's/.*github.com:\(.*\).git.*/\1/g')
if [ -z $commit ]
then
    commit=$(git rev-parse HEAD)
fi

status_code=$(curl \
    -v \
    -s \
    -o github_commit_status.log \
    -w '%{http_code}' \
    "https://api.github.com/repos/$owner_and_repo/statuses/$commit?access_token=$GITHUB_COMMIT_STATUS_TOKEN" \
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
