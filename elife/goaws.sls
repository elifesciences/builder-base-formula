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
        - name: /etc/init.d/goaws
        - source: salt://elife/config/etc-init.d-goaws
        - mode: 755
        - template: jinja
        - require:
            - goaws-install
    service.running:
        - require:
            - cmd: goaws-install
            - file: goaws-init
            - file: /var/run/goaws
        - watch:
            - file: goaws-init

/var/run/goaws:
    file.directory:
        - user: root
        - group: root
        - mode: 700
        - makedirs: True
