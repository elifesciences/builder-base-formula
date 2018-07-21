#!/bin/bash

timeout={{ timeout|default('120') }}
echo "--------"
{% for process, number in processes.iteritems() %}
echo "Current status of {{ number }} {{ process }} processes"
echo "Now is" $(date -Iseconds)
for i in `seq 1 {{ number }}`
do
    #status {{ process }} ID=$i || true
    systemctl status {{ process }}@$i -n 0 || true
done

echo "Stopping asynchronously {{ number }} {{ process }} processes"
echo "Now is" $(date -Iseconds)
for i in `seq 1 {{ number }}`
do
    #(stop {{ process }} ID=$i &) || true
    (systemctl stop {{ process }}@$i &) || true
done
{% endfor %}

{% for process, number in processes.iteritems() %}
for i in `seq 1 {{ number }}`
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
        #status {{ process }} ID=$i 2>&1 | grep "Unknown instance" && break
        systemctl status {{ process }}@$i -n 0 | grep "Active: inactive" && break
        sleep 1
        counter=$((counter + 1))
    done
done
echo "Stopped all {{ process }} processes"
{% endfor %}
{% for process, number in processes.iteritems() %}
echo "Starting {{ number }} {{ process }} processes"
for i in `seq 1 {{ number }}`
do
    #start {{ process }} ID=$i
    systemctl start {{ process }}@$i
done
echo "Started {{ number }} {{ process }} processes"
{% endfor %}
