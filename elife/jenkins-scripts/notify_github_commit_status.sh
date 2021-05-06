#!/bin/bash
# called with envvars:
#   repository=[...] 
#   commit=[...]
#   status=[...] 
#   context=[...] 
#   description='[...]' 
#   target_url='[...]'
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$repository" ]
then
    repository=$("$DIR/github_owner_and_repo.sh")
fi

if [ -z "$commit" ]
then
    commit=$(git rev-parse HEAD)
fi

unique_id=$(uuidgen)
temp_file="github-commit-status-${unique_id}.log"

status_code=$(curl \
    --silent \
    --output "${temp_file}" \
    --write-out '%{http_code}' \
    "https://api.github.com/repos/$repository/statuses/$commit" \
    --header "Authorization: token $GITHUB_TOKEN" \
    --header "Content-Type: application/json" \
    --request POST \
    --data "{\"state\": \"$status\", \"description\": \"$description\", \"context\": \"$context\", \"target_url\": \"$target_url\"}")

if [[ $status_code -eq 201 ]]; then
    rm "${temp_file}"
    exit 0
fi

echo "HTTP ${status_code}"
cat "${temp_file}"
rm "${temp_file}"
exit 22 # standard curl --fail exit code
