include:
    - .www-user
    - .certificates

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
    cmd.script:
        - source: salt://elife/scripts/fastly-ip-ranges.sh
        - timeout: 60 # 1min

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

caddy-certs-snippet:
    file.managed:
        - name: /etc/caddy/snippets/certs
        - source: salt://elife/config/etc-caddy-snippets-certs
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

# note! further caddy configuration won't be validated unless the state does something like:
#   require_in:
#       - cmd: caddy-validate-config
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

# lsh@2024-01-19: removed in favour of Caddy doing it's own (by defalt) log rotation.
# remove once all caddy projects updated.
caddy-logrotate-conf:
    file.absent:
        - name: /etc/logrotate.d/caddy

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
{% if salt['elife.cfg']('cfn.outputs.DomainName') %}
        - listen:
            # schedule caddy restart when certificate is modified
            - etc-certificates-complete-cert
{% endif %}
