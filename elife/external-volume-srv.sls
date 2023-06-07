# Links /srv to /ext/srv
# if /ext is available / mounted (see external-volume.sls)
# Any previously existing content will be moved in that case.

srv-directory:
    file.directory:
        - name: /ext/srv
        - require:
            - mount-external-volume
            - resize-external-volume-if-needed

srv-directory-linked:
    cmd.run:
        - name: (mv /srv/* /ext/srv || true) && rmdir /srv
        - onlyif:
            # lsh@2023-05-17: in salt 3006 file.symlink behaviour has changed and an empty /srv directory now breaks the state.
            # the disabled requisite works well but would prevent the new 'rmdir /srv' from being run.
            # problems moving files from /srv that would have failed the state now fail when rmdir tries to delete a non-empty dir.
            # /srv/ has something in it to move
            #- ls -l /srv/ | grep -v 'total 0'
            # /srv is not already a symlink
            - test ! -L /srv
        - require:
            - srv-directory

    file.symlink:
        - name: /srv
        - target: /ext/srv
        - force: True
        - require:
            - cmd: srv-directory-linked
