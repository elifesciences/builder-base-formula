#!/bin/bash

PATH="${1:-/var/swap.1}"
MB="${2:-1024}"

if free | awk '/^Swap:/ {exit !$2}'; then
    echo "swap space detected, skipping"
else
    echo "no swap space detected, creating swapfile"
    /bin/dd if=/dev/zero of="$PATH" bs=1M count="$MB"
    /sbin/mkswap "$PATH"
    /sbin/swapon "$PATH"
fi

