# Links /srv to /ext/srv
# if /ext is available / mounted (see external-volume.sls)
# Any previously existing content will be moved in that case.

srv-directory:
    file.directory:
        - name: /ext/srv
        - require:
            - mount-external-volume
        - require_in:
            - file: new-ubr-config

srv-directory-linked:
    cmd.run:
        - name: mv /srv/* /ext/srv
        - onlyif:
            # /srv/ has something in it to move
            - ls -l /srv/ | grep -v 'total 0'
            - test ! -L /srv
        - require:
            - srv-directory

    file.symlink:
        - name: /srv
        - target: /ext/srv
        - force: True
        - require:
            - cmd: srv-directory-linked
