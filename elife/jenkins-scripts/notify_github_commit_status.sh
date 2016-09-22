#!/bin/bash
set -e

owner_and_repo=$(git remote -v 2>&1 | grep fetch | sed -e 's/.*github.com:\(.*\).git.*/\1/g')
commit=$(git rev-parse HEAD)

curl \
    -v \
    "https://api.github.com/repos/$owner_and_repo/statuses/$commit?access_token=$GITHUB_COMMIT_STATUS_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"state\": \"$status\", \"description\": \"$description\", \"target_url\": \"$BUILD_URL\"}"
