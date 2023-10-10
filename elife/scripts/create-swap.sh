#!/bin/bash
set -e

swap_path="${1:-/var/swap.1}"
mb="${2:-1024}"

if free | awk '/^Swap:/ {exit !$2}'; then
    echo "swap space detected."
    # "1073741824	/var/swap.1" => "1073741824" => 1024
    actual_b=$(du --bytes --block-size=1 "$swap_path" | cut -f1)
    actual_mb=$((actual_b / 1024 / 1024))
    if [ "$actual_mb" -eq "$mb" ]; then
        echo "swap space correctly sized, skipping."
        exit 0
    fi
    echo "swap space incorrectly sized (have \"$actual_mb\", want \"$mb\"). recreating swapfile."
    /sbin/swapoff "$swap_path" || true
    rm -f "$swap_path"
else
    echo "swap space not detected, creating swapfile."
fi

/bin/dd if=/dev/zero of="$swap_path" bs=1M count="$mb"
chmod 0600 "$swap_path"
/sbin/mkswap "$swap_path"
/sbin/swapon "$swap_path"
