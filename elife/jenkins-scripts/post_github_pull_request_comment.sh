#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
owner_and_repo=$("$DIR/github_owner_and_repo.sh")

status_code=$(curl \
    -v \
    -s \
    -o github_pull_request_comment.log \
    -w '%{http_code}' \
    "https://api.github.com/repos/$owner_and_repo/issues/$number/comments?access_token=$GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"body\": \"$body\"}")

if [[ $status_code -eq 201 ]]; then
    rm github_pull_request_comment.log
    exit 0
fi

cat github_pull_request_comment.log
rm github_pull_request_comment.log
exit 22 # standard curl -f exit code
