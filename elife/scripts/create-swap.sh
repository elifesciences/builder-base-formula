#!/bin/bash
set -e

swap_path="${1:-/var/swap.1}"
mb="${2:-1024}"

if free | awk '/^Swap:/ {exit !$2}'; then
    echo "swap space detected, skipping"
else
    echo "no swap space detected, creating swapfile"
    /bin/dd if=/dev/zero of="$swap_path" bs=1M count="$mb"
    chmod 0600 "$swap_path"
    /sbin/mkswap "$swap_path"
    /sbin/swapon "$swap_path"
fi

