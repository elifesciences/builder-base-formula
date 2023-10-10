# creates a swapfile 
make-swap-space:
    cmd.script:
        - source: salt://elife/scripts/create-swap.sh
        - args: {{ pillar.elife.swap.path }} {{ pillar.elife.swap.size }}

# ensure swap disk is mounted after reboot.
mount-swap-space:
    mount.swap:
        - name: {{ pillar.elife.swap.path }}
        - persist: True
