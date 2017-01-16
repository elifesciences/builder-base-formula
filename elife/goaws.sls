goaws-install:
    cmd.run:
        - name: go get github.com/p4tin/goaws
        - env:
            - GOPATH: /usr/local
        - require:
            - pkg: golang-go
            - aws-cli

goaws-init:

    file.managed:
        - name: /etc/init/goaws-init.conf
        - source: salt://elife/config/etc-init-goaws-init.conf
        - mode: 755
        - template: jinja
        - require:
            - goaws-install

/var/run/goaws:
    file.directory:
        - user: root
        - group: root
        - mode: 700
        - makedirs: True
