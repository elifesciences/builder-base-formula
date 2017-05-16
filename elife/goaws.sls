goaws-install:
    cmd.run:
        - name: |
            go get -d github.com/p4tin/goaws
            cd /usr/local/src/github.com/p4tin/goaws
            git checkout 941608ca3f63bdace571268a241d6835002edd94
            go get github.com/p4tin/goaws
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
    
    service.running:
        - name: goaws-init
        - require:
            - file: goaws-init
