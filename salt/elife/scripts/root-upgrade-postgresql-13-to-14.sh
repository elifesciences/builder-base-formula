#!/bin/bash
# run as *root*, script will switch to user *postgres* as necessary
# upgrades a postgresql 13 database to 14
# assumes 'postgresql-13.sls' has been replaced with 'postgresql-14.sls' and there are two installations present

# docs
# https://www.postgresql.org/docs/13/pgupgrade.html

set -euo pipefail

current_postgres_version=$(ls /var/lib/postgresql)

if [[ $current_postgres_version == "14" ]]; then
    exit
fi

pg_upgradecluster --check -v 14 13 main

pg_upgradecluster -v 14 13 main

echo "Removing cluster 13"
pg_dropcluster 13 main
echo "13 cluster removed"
