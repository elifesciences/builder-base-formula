include:
    - .www-user
    - .certificates

caddy-deps:
    pkg.installed:
        - pkgs:
            - debian-keyring
            - debian-archive-keyring
            - apt-transport-https

{% if false %}

# lsh@2024-04-04: caddy's ppa exceeded it's bandwidth and can't be trusted to be available anymore.
# see: https://github.com/elifesciences/issues/issues/8688
# see: base.sls

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

{% else %}

{% set CADDY_VERSION = pillar.elife.caddy.get('version', "2.7.6") %}
{% set CADDY_TARGZ_HASHES = {
    "2.7.6": {
        "amd64": "99587cf77c595f0bf62cc23c9ea101f9879fa016c7b689d498ce054904821f22",
        "arm64": "6e6aeca09502a8f0ab0a08acd03bb765e80888052d108de22e0698a9160b7235",
    },
    "2.10.2": {
        "amd64": "5c218bc34c9197369263da7e9317a83acdbd80ef45d94dca5eff76e727c67cdd",
        "arm64": "501e955fa634c5aab63247458c3ac655cfdd6cbf1e0436528f41248451c190ac",
    },
} %}
{% set CADDY_HASHES = {
    "2.7.6": {
        "amd64": "db3bfc85bb93160f60fa6df9c3ebf2340dc11740e9a52c717d88a14c0430f229",
        "arm64": "dc49543c4cbf7a770acdb3cf63cb23b251719ef79d9861977d36cd8c3e54b384",
    },
    "2.10.2": {
        "amd64": "4ef1f68c70219536b2711fd16547a79841a2dec2d6b4e56b1e3e5e9da76028e6",
        "arm64": "6f297c7f4807d9e4d54137de4dc26fe51e9ddf9c2dae69bc6762d05330a77984",
    },
} %}

caddy-pkg:
    archive.extracted:
        - name: /root/caddy-{{ CADDY_VERSION }}
        - source: "https://github.com/caddyserver/caddy/releases/download/v{{ CADDY_VERSION }}/caddy_{{ CADDY_VERSION }}_linux_{{ grains['osarch'] }}.tar.gz"
        - source_hash: {{ CADDY_TARGZ_HASHES[CADDY_VERSION][grains['osarch']] }}
        - enforce_toplevel: false
        - if_missing: /root/caddy-{{ CADDY_VERSION }}/caddy

    file.managed:
        - name: /usr/bin/caddy
        - source: /root/caddy-{{ CADDY_VERSION }}/caddy
        - source_hash: {{ CADDY_HASHES[CADDY_VERSION][grains['osarch']] }}
        - mode: 755
        - require:
            - archive: caddy-pkg

{% endif %}

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
        - template: jinja
        - require:
            - caddy-pkg

caddy-cve-2025-64459-mitigation-snippet:
    file.managed:
        - name: /etc/caddy/snippets/cve_2025_64459_mitigation
        - source: salt://elife/config/etc-caddy-snippets-cve_2025_64459_mitigation
        - makedirs: True
        - require:
            - caddy-pkg
remove-caddy-cve-2025-64459-mitigation-snippet-with-conf-ext:
    file.absent:
        - name: /etc/caddy/snippets/cve_2025_64459_mitigation.conf

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

caddy-ondemand-site:
    file.managed:
        - name: /etc/caddy/sites.d/tls-ondemand
        - source: salt://elife/config/etc-caddy-sites.d-tls-ondemand
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

    # There is a bug with salt that sometimes means the service.running state isn't reloading
    # So we explicitly reload it
    module.run:
        - name: service.systemctl_reload
        - require:
            - file: caddy-server-service

    service.running:
        - name: caddy
        - enable: true
        - require:
            - file: caddy-server-service
            - module: caddy-server-service
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
