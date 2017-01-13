goaws-install:
    cmd.run:
        - name: go get github.com/p4tin/goaws
        - env:
            - GOPATH: /usr/local
        - require:
            - pkg: golang

goaws-init:
    file.managed:
        - name: /etc/init.d/goaws
        - source: salt://elife/config/etc-init.d-goaws
        - require:
            - goaws-install
    service.running:
        - require:
            - cmd: goaws-install
            - file: goaws-init
        - watch:
            - file: goaws-init
