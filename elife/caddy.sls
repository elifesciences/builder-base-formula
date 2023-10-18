include:
    - .certificates

# typically created by the webserver package. caddy instead creates a user+group called 'caddy'.
# uwsgi and php-fpm rely on a www-data user existing
webserver-user-group:
    group.present:
        - name: {{ pillar.elife.webserver.username }}

    user.present:
        - name: {{ pillar.elife.webserver.username }}
        - groups:
            - www-data
        - require:
            - group: webserver-user-group

caddy-deps:
    pkg.installed:
        - pkgs:
            - debian-keyring
            - debian-archive-keyring
            - apt-transport-https

caddy-gpg-present:
    cmd.run:
        - name: |
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
        - require:
            - caddy-deps
        - unless:
            - test -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg

caddy-pkg-list-present:
    cmd.run:
        - name: |
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
        - require:
            - caddy-deps
        - unless:
            - test -f /etc/apt/sources.list.d/caddy-stable.list

caddy-pkg:
    pkg.installed:
        - name: caddy
        - refresh: true # apt-get update prior to installation
        - require:
            - caddy-deps
            - caddy-gpg-present
            - caddy-pkg-list-present

caddy-config:
    file.managed:
        - name: /etc/caddy/Caddyfile
        - source: salt://elife/config/etc-caddy-Caddyfile
        - template: jinja
        - require:
            - caddy-pkg

caddy-tls-config:
    file.managed:
        - name: /etc/caddy/conf.d/tls
        - source: salt://elife/config/etc-caddy-conf.d-tls
        - template: jinja
        - makedirs: True
        - require:
            - caddy-pkg

caddy-metrics-config:
    file.managed:
        - name: /etc/caddy/conf.d/metrics
        - source: salt://elife/config/etc-caddy-conf.d-metrics
        - template: jinja
        - makedirs: True
        - require:
            - caddy-pkg

caddy-metrics-site:
    file.managed:
        - name: /etc/caddy/sites.d/metrics
        - source: salt://elife/config/etc-caddy-sites.d-metrics
        - makedirs: true
        - require:
            - caddy-pkg

caddy-validate-config:
    cmd.run:
        - name: caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
        - require:
            - caddy-config
            - caddy-tls-config
            - caddy-metrics-config
            - caddy-metrics-site

caddy-server-service:
    file.managed:
        - name: /lib/systemd/system/caddy.service
        - source: salt://elife/config/lib-systemd-system-caddy.service
        - template: jinja
        - require:
            - caddy-pkg
            - caddy-config

    service.running:
        - name: caddy
        - enable: true
        - require:
            - file: caddy-server-service
            - caddy-pkg
            - caddy-validate-config
        - watch:
            - caddy-config
