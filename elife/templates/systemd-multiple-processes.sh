#!/bin/bash
# deprecated: use `systemctl restart process@{1..N}`

NUMBER={{ number }}
timeout=120
echo "--------"
echo "Current status of $NUMBER {{ process }} processes"
echo "Now is" $(date -Iseconds)
for i in `seq 1 $NUMBER`
do
    systemctl status {{ process }}@$i -n 0 || true
done

echo "Stopping $NUMBER {{ process }} processes"
echo "Now is" $(date -Iseconds)
for i in `seq 1 $NUMBER`
do
    (systemctl stop {{ process }}@$i &) || true
done

for i in `seq 1 $NUMBER`
do
    echo "Waiting for {{ process }} $i to stop"
    echo "Now is" $(date -Iseconds)
    counter=0
    while true
    do
        if [ "$counter" -gt "$timeout" ]
        then
            echo "It shouldn't take more than $timeout seconds to kill all the {{ process }} processes"
            exit 1
        fi
        systemctl status {{ process }}@$i -n 0 | grep "Active: inactive" && break
        sleep 1
        counter=$((counter + 1))
    done
done
echo "Stopped all {{ process }} processes"
echo "Starting $NUMBER {{ process }} processes"
for i in `seq 1 $NUMBER`
do
    systemctl start {{ process }}@$i
done
echo "Started $NUMBER {{ process }} processes"
