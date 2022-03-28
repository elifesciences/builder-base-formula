#!/bin/bash
# grants given permissions ('grants') to given user, with given password, for given host, on given databases in mysql.
# connects without password as the mysql 'root' user.
# run as the system root user.
# run only on 20.04/MySQL 8
set -exu

user="${1:-{{ user }}}"
pass="${2:-{{ pass }}}"
host="${3:-{{ host }}}"
db="${4:-{{db}}}"
grants="${5:-{{ grants }}}"

mysql << eof
CREATE USER IF NOT EXISTS '$user'@'$host' IDENTIFIED BY '$pass';
GRANT $grants ON $db TO '$user'@'$host';
eof
