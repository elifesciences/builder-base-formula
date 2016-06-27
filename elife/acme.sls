{% set fqdn = salt['elife.cfg']('cfn.outputs.DomainName') %}

letsencrypt-deps:
    pkg.installed:
        - pkgs:
            - python
            - python-dev
            - python-virtualenv
            - gcc
            - dialog
            - libaugeas0
            - libssl-dev # this is ~ 45MB+ 
            - libffi-dev
            - ca-certificates

install-letsencrypt:
    # this bugs the hell out of me. for some reason 
    # `force_reset` and `force_checkout` in `git.latest` aren't working
    cmd.run:
        - name: cd /opt/letsencrypt && git reset --hard 
        - onlyif:
            - test -d /opt/letsencrypt

    git.latest:
        - name: https://github.com/letsencrypt/letsencrypt 
        - target: /opt/letsencrypt
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - require:
            - cmd: install-letsencrypt
            - pkg: letsencrypt-deps

    # client prefers to sudo everything
    file.directory:
        - name: /opt/letsencrypt
        - user: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
        - require:
            - git: install-letsencrypt

acme-config:
    file.managed:
        - name: /etc/letsencrypt/cli.ini
        - source: salt://elife/config/etc-letsencrypt-cli.ini
        - template: jinja
        - makedirs: True

# simple script to call that fetches a cert using above config
acme-fetch-certs-script:
    file.managed:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /opt/letsencrypt/fetch-ssl-certs.sh
        - source: salt://elife/scripts/fetch-ssl-certs.sh
        - mode: 700
        - template: jinja
        - require:
            - file: install-letsencrypt

{% if pillar.elife.dev %}
clear-vhosts:
    cmd.script:
        - source: salt://elife/scripts/nuke-vhost-restart-webserver.sh 

acme-fetch-certs:
    cmd.run:
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /opt/letsencrypt/
        - name: ./fetch-ssl-certs.sh
        - require:
            - file: acme-config
            - file: acme-fetch-certs-script
            - cmd: clear-vhosts

        - unless:
            # certs exist. originally created here, but later refreshed by cron
            - sudo test -f /etc/letsencrypt/live/{{ fqdn }}/cert.pem
            - sudo test -f /etc/letsencrypt/live/{{ fqdn }}/privkey.pem
            - sudo test -f /etc/letsencrypt/live/{{ fqdn }}/fullchain.pem

    # first of every month
    cron.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - identifier: fetch-certs-every-month
        - name: /opt/letsencrypt/fetch-ssl-certs.sh
        - minute: 0
        - hour: 0
        - daymonth: 1
        - require:
            - file: acme-fetch-certs-script
            - cmd: clear-vhosts
{% endif %}

