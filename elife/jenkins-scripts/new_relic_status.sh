#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: new_relic_status.sh APPLICATION_ID"
    echo "Example: new_relic_status.sh 29775807"
    echo "Returns the status color of APM/Browser monitoring. Values: red, orange, green, unknown"
    exit 1
fi

application_id="$1"
curl -v "https://api.newrelic.com/v2/applications/${application_id}.json" -H "X-Api-Key: ${NEW_RELIC_REST_API_KEY}" | jq -r .application.health_status

