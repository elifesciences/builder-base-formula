#!/bin/bash
set -eu

to_match=$1
log_file=/var/log/upstart-monitoring.log
set -o pipefail
initctl list | grep $to_match | tee -a $log_file | grep /running || {
    echo "Error in upstart-monitoring: ${status}"
    logger "Upstart job is stopped: $to_match ($log_file on $(hostname))"
    exit $status
}

