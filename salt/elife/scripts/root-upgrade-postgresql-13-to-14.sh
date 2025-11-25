#!/bin/bash
# run as *root*, script will switch to user *postgres* as necessary
# upgrades a postgresql 13 database to 14
# assumes 'postgresql-13.sls' has been replaced with 'postgresql-14.sls' and there are two installations present

# docs
# https://www.postgresql.org/docs/13/pgupgrade.html

set -eu

# check that 13 still exists as this script will purge it after the data has been upgraded
test -d /var/lib/postgresql/13 || {
    echo "postgresql 13 not detected, nothing to upgrade"
    exit 0
}

# stop all postgresql servers
# /lib/systemd/system/postgresql.service is being used as a target rather than a service.
# /lib/systemd/system/postgresql@.service template runs psql 9, 11, 13 etc and depends on above service.
echo "stopping postgresql ..."
systemctl stop postgresql

sleep 2 # give all psql services time to stop

# ensure postgresql is running when the script exits
#function finish {
#    # if pg_upgrade fails we want the states dependent on psql to also fail
#    # if it succeeds it will have it's config replaced immediately and restarted
#    #systemctl start postgresql # so this is unnecessary
#    echo "done"
#}
#trap finish EXIT

# the actual services are:
# postgresql@14-main.service
# postgresql@13-main.service

# stopping the target (postgresql.service) will stop the services that depend upon it

# "Always run the pg_upgrade binary of the new server"
# - https://www.postgresql.org/docs/14/pgupgrade.html

# $ locate pg_upgrade
# ...?
# /usr/lib/postgresql/14/bin/pg_upgrade

pg_upgrade="/usr/lib/postgresql/14/bin/pg_upgrade"
echo "using: $pg_upgrade"

# we have two upgrade modes available to us: link and copy (default)
# link upgrades the existing data in-place, is faster and uses less disk space but destroys original cluster and requires a shared fs.
# copy upgrades are slower, doubles the disk space but you retain the old data

# we'll stick with the default (copy)

# the 'datadir' on Ubuntu can be found by issuing:
# psql -U root postgres -c "SHOW data_directory"
#        data_directory
#------------------------------
# /var/lib/postgresql/13/main
#(1 row)

(
    cd /tmp # pg_upgrade writes logs to the current working directory
    rm -f /tmp/pg_upgrade_* # remove any old logs else they get appended to

    printf "\npg_upgrade: ---\n\n"

    # postgresql.conf doesn't live in /var/lib/postgresql/$version/main/ like it expects to:
    # 'postgres cannot access the server configuration file "/var/lib/postgresql/13/main/postgresql.conf": No such file or directory'
    # on Ubuntu it lives here: /etc/postgresql/13/main/postgresql.conf
    # so we need to pass in more parameters

    user=postgres
    sudo -u "$user" "$pg_upgrade" \
        --old-datadir "/var/lib/postgresql/13/main" \
        --new-datadir "/var/lib/postgresql/14/main" \
        --old-bindir "/usr/lib/postgresql/13/bin" \
        --new-bindir "/usr/lib/postgresql/14/bin" \
        --old-options "-c config_file=/etc/postgresql/13/main/postgresql.conf" \
        --new-options "-c config_file=/etc/postgresql/14/main/postgresql.conf" \
    && {
        # pg_upgrade succeeded

        # create a backup of the data
        #bdir=/tmp/var-lib-postgresql-13--backup/
        #mkdir -p "$bdir"
        #rsync -av /var/lib/postgresql/13/ "$bdir"
        #tar czf "/tmp/$bdir.tar.gz" "$bdir"

        #echo "wrote backup: $bdir.tar.gz"

        # remove postgresql-13
        echo "removing postgresql-13 including data and configuration"
        DEBIAN_FRONTEND=noninteractive apt-get purge postgresql-13 -y
    } \
    || {
        # pg upgrade failed

        printf "\npg_upgrade failed."
        printf "\npg_upgrade logs: ---\n\n"

        cat /tmp/pg_upgrade_*
    }
)
