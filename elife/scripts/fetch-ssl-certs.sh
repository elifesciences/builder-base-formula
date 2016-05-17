#!/bin/bash
# fetch ssl certs using the letsencrypt-auto client
set -e
mkdir -p /tmp/letsencrypt-auto
cd /opt/letsencrypt/
./letsencrypt-auto certonly --verbose "$@"
