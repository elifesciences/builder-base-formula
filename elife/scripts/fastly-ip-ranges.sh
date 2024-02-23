#!/bin/bash
# downloads Fastly's IP addresses so Caddy can trust them. 
# Trusing these IPs means Caddy will set the correct forwarded headers on requests.
set -eu -o pipefail
rm -f /tmp/fastly-ip-ranges
curl --silent "https://api.fastly.com/public-ip-list" | jq -r '.[][]' | sed -z 's/\n/ /g' > /tmp/fastly-ip-ranges
