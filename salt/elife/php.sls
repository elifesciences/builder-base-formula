{% set php_version = pillar.elife.php.get('version', '8.4') %}

{% set extra_extensions = pillar.elife.php.get('extra_extensions', []) %}

{% set packages = [
    'fpm',
    'cli',
    'mbstring',
    'mysql',
    'xsl',
    'gd',
    'curl',
    'xml',
    'common',
] + extra_extensions %}

php-ppa:
    pkgrepo.managed:
       - name: deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu {{ salt['grains.get']('oscodename') }} main
       - keyid: 4f4ea0aae5267a6c
       - keyserver: keyserver.ubuntu.com
       - refresh_db: true

php-clean-packages:
    cmd.run:
        - name: apt-get -y remove php-*
        - onlyif: dpkg -l php-* | grep ii | grep -v php-common | grep -v php{{ php_version }}

php:
    pkg.installed:
        - pkgs:
            {% for package in packages %}
            - php{{ php_version }}-{{ package }}
            {% endfor %}
        - require:
            - php-clean-packages
            - php-ppa
            - pkg: base
        - install_recommends: False
        - refresh: True

php-ppa-migrate:
    pkg.latest:
        - pkgs:
            {% for package in packages %}
            - php{{ php_version }}-{{ package }}
            {% endfor %}
        - require_in:
            - php
        - onchanges:
            - php-ppa
        - install_recommends: False

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
        - source: salt://elife/config/etc-php-cli-php.ini
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

{% if pillar.elife.php.get('fpm', False) %}
php-fpm-deps:
    pkg.installed:
        - name: php{{ php_version }}-fpm
        - require:
            - php

php-fpm-config:
    file.managed:
        - name: /etc/php/{{ php_version }}/fpm/php.ini
        - source: salt://elife/config/etc-php-fpm-php.ini
        - template: jinja
        - require:
            - php-fpm-deps
            - php-log

php-fpm-pool:
    file.managed:
        - name: /etc/php/{{ php_version }}/fpm/pool.d/www.conf
        - source: salt://elife/config/etc-php-fpm-pool.d-www.conf
        - template: jinja
        - require:
            - php-fpm-deps

# favoring php_errors.log for everything
not-used-php-log:
    file.absent:
        - name: /var/log/php{{ php_version }}-fpm.log

php-fpm:
    service.running:
        - name: php{{ php_version }}-fpm
        - enable: True
        - require:
            - file: php-fpm-config
            - php-fpm-pool
        - watch:
            - pkg: php-fpm-deps
            - file: php-fpm-config
            - file: php-fpm-pool

php-cachetool:
    file.managed:
        - name: /usr/local/bin/cachetool
        - source: https://s3.amazonaws.com/elife-builder/packages/cachetool.phar # 3.0.0
        - source_hash: md5=fa7ce33b37dba2642329b9a6bdc720b1

    cmd.run:
        - name: chmod +x /usr/local/bin/cachetool
        - require:
            - file: php-cachetool

php-cachetool-config:
    file.managed:
        - name: /etc/cachetool.yml
        - source: salt://elife/config/etc-cachetool.yml

{% endif %}
