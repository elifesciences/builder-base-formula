#!/bin/bash
set -eu -o pipefail
rm -f /tmp/fastly-ip-ranges
curl --silent "https://api.fastly.com/public-ip-list" | jq -r '.[][]' | sed -z 's/\n/ /g' > /tmp/fastly-ip-ranges
