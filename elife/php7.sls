# base php installation

# 14.04 has php5.5 and requires a ppa for 7.0
# 16.04 has php7.0
# 18.04 has php7.2

{% set osrelease = salt['grains.get']('osrelease') %}
{% set php_version = '7.0' %}

{% if osrelease == "18.04" %}

    {% set php_version = '7.2' %}

php-ppa:
    cmd.run:
        - name: |
            echo "WARNING: state 'php-ppa' is deprecated. use 'php' instead."

{% elif osrelease == "16.04" %}

php-ppa:
      pkgrepo.managed:
        - name: deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main
        - dist: xenial
        - file: /etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list
        - keyserver: keyserver.ubuntu.com
        - keyid: E5267A6C
        - refresh_db: true
        - unless:
            - test -e /etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list

{% else %}

# still problematic in 16.04:
# https://github.com/saltstack/salt/issues/32294

php-ppa:
    cmd.run:
        - name: apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
        - unless:
            - apt-key list | grep E5267A6C

    # https://launchpad.net/~ondrej/+archive/ubuntu/php
    pkgrepo.managed:
        - humanname: Ondřej Surý PHP PPA
        # there was a name change from "php-{{ php_version }}" to just "php"
        - ppa: ondrej/php
        #- keyid: E5267A6C # 2016-11-11, LSH: doesn't seem to work
        - keyserver: keyserver.ubuntu.com
        - file: /etc/apt/sources.list.d/ondrej-php-trusty.list
        - require:
            - cmd: php-ppa
        - unless:
            - test -e /etc/apt/sources.list.d/ondrej-php-trusty.list


{% endif %}

php:
    pkg.installed:
        - pkgs:
            - php{{ php_version }}-cli
            - php{{ php_version }}-mbstring
            - php{{ php_version }}-mysql
            - php{{ php_version }}-xsl
            - php{{ php_version }}-gd
            - php{{ php_version }}-curl
            # required by proofreader-php, provides 'ext-dom', required by 'theseer/fdomdocument'
            - php{{ php_version }}-xml
            {% if osrelease != '18.04' %}
            # php-mcrypt deprecated in 7.1 and removed in 7.2
            - php{{ php_version }}-mcrypt
            {% endif %}
        - require:
            - php-ppa # DEPRECATED
            - pkg: base

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
