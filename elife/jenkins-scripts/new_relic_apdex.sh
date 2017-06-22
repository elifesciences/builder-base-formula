#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: new_relic_apdex.sh APPLICATION_ID"
    echo "Example: new_relic_apdex.sh 29775807"
    echo "Returns the APM current apdex"
    exit 1
fi

application_id="$1"
curl -v "https://api.newrelic.com/v2/applications/${application_id}.json" -H "X-Api-Key: ${NEW_RELIC_REST_API_KEY}" | jq -r .application.application_summary.apdex_score

