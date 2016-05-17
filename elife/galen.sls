download-galen:
    cmd.run:
        - cwd: /opt/
        - name: |
            set -e
            wget https://github.com/galenframework/galen/releases/download/galen-2.1.3/galen-bin-2.1.3.zip --continue
            unzip galen-bin-2.1.3.zip
            rm galen-bin-2.1.3.zip
            # the install script is very basic, just replicate a few of it's steps here
            ln -sfT galen-bin-2.1.3 galen
            ln -sfT /opt/galen/galen /usr/bin/galen
        - unless:
            - test -h /opt/galen # symlinked dir exists
