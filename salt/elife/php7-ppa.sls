{% set osrelease = salt['grains.get']('osrelease') %}

# base php installation
# 18.04 has php7.2
# 20.04 has php7.4 - but! Ubuntu has frozen it at around 7.4.3 but PHP is at 7.4.30+ at time of writing
# 22.04 has php8.1

# php8-ppa has php8.1

{% set php_version = '7.4' %}

php-ppa:
    # lsh@2023-03-20: doesn't work, known salt bug with unicode chars
    #pkgrepo.managed:
    #    - name: deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu {{ salt['grains.get']('oscodename') }} main
    #    - keyid: 4f4ea0aae5267a6c
    #    - keyserver: keyserver.ubuntu.com
    #    - refresh_db: true
    cmd.run:
        - name: "apt-add-repository -y ppa:ondrej/php"
        - env:
            - LC_ALL: 'en_US.UTF-8'
        - unless:
            - test -f /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list

php:
    pkg.installed:
        - pkgs:
            - php{{ php_version }}-cli
            - php{{ php_version }}-mbstring
            - php{{ php_version }}-mysql
            - php{{ php_version }}-xsl
            - php{{ php_version }}-gd
            - php{{ php_version }}-curl
            # lsh@2023-06-7: disabled installation. only experimental journal-cms instances are using php8 right now.
            # required by proofreader-php, provides 'ext-dom', required by 'theseer/fdomdocument'
            #- php{{ php_version }}-xml
        - require:
            - php-ppa
            - pkg: base

php-dev:
    pkg.installed:
        - pkgs:
            - php{{ php_version }}-dev
        - require:
            - php

php-log:
    file.managed:
        - name: /var/log/php_errors.log
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - mode: 660
        - replace: False

php-cli-config:
    file.managed:
        - name: /etc/php/{{ php_version }}/cli/php.ini
        - source: salt://elife/config/etc-php-{{ php_version }}-cli-php.ini
        - template: jinja
        - require:
            - php
            - php-log

syslog-ng-for-php-log:
    file.managed:
        - name: /etc/syslog-ng/conf.d/php.conf
        - source: salt://elife/config/etc-syslog-ng-conf.d-php.conf
        - template: jinja
        - require:
            - pkg: syslog-ng
        - listen_in:
            - service: syslog-ng
    
logrotate-for-php-log:
    file.managed:
        - name: /etc/logrotate.d/php
        - source: salt://elife/config/etc-logrotate.d-php
