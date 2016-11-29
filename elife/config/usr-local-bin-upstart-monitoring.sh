#!/bin/bash
set -eu

if [ "$#" -ne 1 ]
then
    echo "Usage: $0 process-name-or-part-of-it"
    exit 1
fi

to_match=$1
log_file=/var/log/upstart-monitoring.log
set -o pipefail
initctl list | grep "^$to_match " | tee -a $log_file | grep /running || {
    echo "Error in upstart-monitoring: no job matching ${to_match} is running"
    logger "Upstart job matching $to_match is stopped ($log_file on $(hostname))"
    exit 2
}

