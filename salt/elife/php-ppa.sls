{% set osrelease = salt['grains.get']('osrelease') %}

{% set php_version = pillar.elife.php.version %}

{% set uninstall_versions = [
  '7.1',
  '7.2',
  '7.3',
  '7.4',
  '8.0',
  '8.1',
  '8.2',
  '8.3',
  '8.4',
] %}
{% set nothing = uninstall_versions.remove(php_version) %}

php-ppa:
    pkgrepo.managed:
       - name: deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu {{ salt['grains.get']('oscodename') }} main
       - keyid: 4f4ea0aae5267a6c
       - keyserver: keyserver.ubuntu.com
       - refresh_db: true

php-clean:
    pkg.removed:
        - pkgs:
            {% for remove_version in uninstall_versions %}
            - php{{ remove_version }}-fpm
            - php{{ remove_version }}-cli
            - php{{ remove_version }}-mbstring
            - php{{ remove_version }}-mysql
            - php{{ remove_version }}-xsl
            - php{{ remove_version }}-gd
            - php{{ remove_version }}-curl
            - php{{ remove_version }}-xml
            - php{{ remove_version }}-common
            {% endfor %}
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
            - php-clean
            - php-ppa
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

{% if pillar.elife.php.fpm %}
php-fpm-deps:
    pkg.installed:
        - name: php{{ php_version }}-fpm
        - require:
            - php

php-fpm-config:
    file.managed:
        - name: /etc/php/{{ php_version }}/fpm/php.ini
        - source: salt://elife/config/etc-php-{{ php_version }}-fpm-php.ini
        - template: jinja
        - require:
            - php-fpm-deps
            - php-log

php-fpm-pool:
    file.managed:
        - name: /etc/php/{{ php_version }}/fpm/pool.d/www.conf
        - source: salt://elife/config/etc-php-{{ php_version }}-fpm-pool.d-www.conf
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
