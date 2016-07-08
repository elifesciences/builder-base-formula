# temporary state
# this project has removed it's dependency on the 'daemon' tool
# remove the package and kill any processes still using it

remove-daemon-app:
    pkg.removed:
        - name: daemon
    
    cmd.run:
        # forcibly kill anything using the 'daemon' app
        - name: killall daemon --signal 9 --quiet || true
