# base php installation

{% if salt['grains.get']('osrelease') == "16.04" %}

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
        # there was a name change from "php-7.0" to just "php"
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
            - php7.0-cli
            - php7.0-mbstring
            - php7.0-mysql
            - php7.0-xsl
            - php7.0-gd
            - php7.0-curl
            - php7.0-mcrypt
        - require:
            - pkgrepo: php-ppa
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
        - name: /etc/php/7.0/cli/php.ini
        - source: salt://elife/config/etc-php-7.0-cli-php.ini
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
