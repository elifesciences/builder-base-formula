include:
    - .certificates

# traditionally created by apache/nginx, caddy instead creates a user+group called 'caddy'.
# uwsgi and php-fpm rely on a www-data user existing,
# and their socket files are owned by www-data.
# caddy must run as www-data in order to seamlessly keep using socket.
# socket permissions are currently affected by systemd, uwsgi and it's 'ExecPreStart' hack in the service file.
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

caddy-user-in-www-user-group:
    user.present:
        - name: caddy
        - groups:
            - www-data
        - require:
            - webserver-user-group

caddy-config:
    file.managed:
        - name: /etc/caddy/Caddyfile
        - source: salt://elife/config/etc-caddy-Caddyfile
        - template: jinja
        - require:
            - caddy-pkg

caddy-auto-https-config:
    file.managed:
        - name: /etc/caddy/conf.d/auto_https
        - source: salt://elife/config/etc-caddy-conf.d-auto_https
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

caddy-error-pages-site:
    file.managed:
        - name: /etc/caddy/sites.d/error-pages
        - source: salt://elife/config/etc-caddy-sites.d-error-pages
        - makedirs: True
        - require:
            - caddy-pkg

caddy-validate-config:
    cmd.run:
        - name: caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
        - require:
            - caddy-config
            - caddy-auto-https-config
            - caddy-metrics-config
            - caddy-metrics-site

caddy-log-dir:
    file.directory:
        - name: /var/log/caddy
        - makedirs: true
        - user: caddy
        # lsh@2023-10-27: caddy service is running as www-data and needs permissions to write logs.
        - group: www-data
        - dir_mode: 775
        - file_mode: 664
        - recurse:
            - user
            - group
            - mode

caddy-logrotate-conf:
    file.managed:
        - name: /etc/logrotate.d/caddy
        - source: salt://elife/config/etc-logrotate.d-caddy
        - template: jinja
        - require:
            - caddy-log-dir

caddy-server-service:
    file.managed:
        - name: /lib/systemd/system/caddy.service
        - source: salt://elife/config/lib-systemd-system-caddy.service
        - template: jinja
        - require:
            - caddy-pkg
            - caddy-config
            - caddy-user-in-www-user-group
            - caddy-log-dir

    service.running:
        - name: caddy
        - enable: true
        - require:
            - file: caddy-server-service
            - caddy-pkg
            - caddy-validate-config
        - watch:
            - caddy-config
            - caddy-auto-https-config
            - caddy-metrics-config
            - caddy-metrics-site
