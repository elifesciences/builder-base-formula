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
            - golang-go
            - aws-cli

goaws-run-dir:
    file.directory:
        - name: /var/run/goaws
        - mode: 755

goaws-init-upstart:
    file.managed:
        - name: /etc/init/goaws-init.conf
        - source: salt://elife/config/etc-init-goaws-init.conf
        - mode: 755
        - template: jinja

goaws-init-systemd:
    file.managed:
        - name: /lib/systemd/system/goaws.service
        - source: salt://elife/config/lib-systemd-system-goaws.service
        - template: jinja

{% set xenial = salt['grains.get']('oscodename') == 'xenial' %}
goaws-init:
    service.running:
        - name: {% if xenial %}goaws{% else %}goaws-init{% endif %}
        - require:
            - goaws-install
            - goaws-run-dir
            - goaws-init-systemd
            - goaws-init-upstart
