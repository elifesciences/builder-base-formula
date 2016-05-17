#!/bin/bash
if free | awk '/^Swap:/ {exit !$2}'; then
    echo "swap space detected, skipping"
else
    echo "no swap space detected, creating swapfile"
    /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
    /sbin/mkswap /var/swap.1
    /sbin/swapon /var/swap.1
fi

