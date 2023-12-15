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
        - home: /var/www
        - createhome: true
        - groups:
            - www-data
        - require:
            - group: webserver-user-group

# lsh@2023-12-15: unnecessary on new machines as /var/www `webserver-user-group` *should* create writable /var/www. untested.
# caddy depends on the webserver user's home dir (/var/www) to write:
# * OCSP staple file
# * ...
webserver-user-can-write-var-www:
    file.directory:
        - name: /var/www
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - require:
            - webserver-user-group
        - listen_in:
            - service: caddy-server-service

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

# caddy can include the contents of a file with it's `import` directive.
# - https://caddyserver.com/docs/caddyfile/directives/import
caddy-snippet-dir:
    file.directory:
        - name: /etc/caddy/snippets
        - makedirs: True
        - require:
            - caddy-pkg

fastly-ip-ranges:
    cmd.run:
        - name: |
            set -eo pipefail
            rm -f /tmp/fastly-ip-ranges
            curl --silent "https://api.fastly.com/public-ip-list" | jq -r '.[][]' | sed -z 's/\n/ /g' > /tmp/fastly-ip-ranges

# caddy will replace the X-Forwarded-* headers with the *actual* values *unless* the request comes from a trusted proxy.
# `journal` and `api-gateway` are in front of Fastly but other Caddy instances downstream may need to trust `api-gateway`.
# nginx instances won't modify the X-Forwarded-* headers and should be fine.
caddy-trusted-proxy-ip-ranges-snippet:
    file.managed:
        - name: /etc/caddy/snippets/trusted-proxy-ip-ranges
        - source: /tmp/fastly-ip-ranges
        - onlyif:
            # file exists and is not empty
            - test -s /tmp/fastly-ip-ranges
        - require:
            - fastly-ip-ranges
            - caddy-snippet-dir

# use in concert with `nginx-error-pages.sls` (not nginx-specific)
caddy-error-pages-snippet:
    file.managed:
        - name: /etc/caddy/snippets/error-pages
        - source: salt://elife/config/etc-caddy-snippets-error-pages
        - makedirs: True
        - require:
            - caddy-pkg

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

caddy-trusted-proxy-ip-ranges-config:
    file.managed:
        - name: /etc/caddy/conf.d/trusted-proxy-ip-ranges
        - source: salt://elife/config/etc-caddy-conf.d-trusted-proxy-ip-ranges
        - require:
            - caddy-trusted-proxy-ip-ranges-snippet

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
            - caddy-auto-https-config
            - caddy-metrics-config
            - caddy-trusted-proxy-ip-ranges-config
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
            - caddy-trusted-proxy-ip-ranges-snippet
            - caddy-error-pages-snippet
            - caddy-config
            - caddy-auto-https-config
            - caddy-metrics-config
            - caddy-trusted-proxy-ip-ranges-config
            - caddy-metrics-site

