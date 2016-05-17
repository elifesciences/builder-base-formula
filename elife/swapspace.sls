# creates a 1GB swapfile 
make-swap-space:
    cmd.script:
        - source: salt://elife/scripts/create-swap.sh
