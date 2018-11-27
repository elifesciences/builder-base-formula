#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$owner_and_repo" ]
then
    owner_and_repo=$("$DIR/github_owner_and_repo.sh")
fi

if [ -z "$commit" ]
then
    commit=$(git rev-parse HEAD)
fi

unique_id=$(uuidgen)
temp_file="github-commit-status-${unique_id}.log"

status_code=$(curl \
    -s \
    -o "${temp_file}" \
    -w '%{http_code}' \
    "https://api.github.com/repos/$owner_and_repo/statuses/$commit?access_token=$GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"state\": \"$status\", \"description\": \"$description\", \"context\": \"$context\", \"target_url\": \"$target_url\"}")

if [[ $status_code -eq 201 ]]; then
    rm "${temp_file}"
    exit 0
fi

echo "HTTP ${status_code}"
cat "${temp_file}"
rm "${temp_file}"
exit 22 # standard curl -f exit code
