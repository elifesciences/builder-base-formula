# node exporter, part of Prometheus.
# it starts a http server and responds to requests for /metrics
# do not configure to listen on a public IP.

node_exporter-user-group:
    group.present:
        - name: node_exporter

    user.present:
        - name: node_exporter
        - shell: /bin/false
        - groups:
            - node_exporter
        - require:
            - group: node_exporter

node_exporter-installation:
    archive.extracted:
        - name: /srv
        - source: https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
        - source_hash: ecc41b3b4d53f7b9c16a370419a25a133e48c09dfc49499d63bcc0c5e0cf3d01
        - if_missing: /srv/node_exporter

    file.symlink:
        - name: /srv/node_exporter
        - target: /srv/node_exporter-1.6.1.linux-amd64
        - force: true
        - require:
            - archive: node_exporter-installation

node_exporter-ownership:
    file.directory:
        - name: /srv/node_exporter
        - allow_symlink: true
        - user: node_exporter
        - group: node_exporter
        - recurse:
            - user
            - group
        - require:
            - node_exporter-user-group
            - node_exporter-installation

node_exporter-systemd-service:
    file.managed:
        - name: /lib/systemd/system/node_exporter.service
        - source: salt://monitor/config/lib-systemd-system-node_exporter.service

    service.running:
        - name: node_exporter
        - enable: true
        - require:
            - file: node_exporter-systemd-service
            - node_exporter-installation
            - node_exporter-ownership

