#
# bridges Nginx and PHP 7
# depends on elife/php7.sls
# 
#
{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == "18.04" %}
{% set php_version = '7.2' %}
{% else %}
{% set php_version = '7.0' %}
{% endif %}


php-nginx-deps:
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
            - php-nginx-deps
            - php-log

php-fpm-pool:
    file.managed:
        - name: /etc/php/{{ php_version }}/fpm/pool.d/www.conf
        - source: salt://elife/config/etc-php-{{ php_version }}-fpm-pool.d-www.conf
        - template: jinja
        - require:
            - php-nginx-deps

# favoring php_errors.log for everything
not-used-php-log:
    file.absent:
        - name: /var/log/php{{ php_version }}-fpm.log

php-fpm:
    # nginx config needs to target this sock file. 
    # easier to target when version stripped out
    file.symlink:
        - name: /var/php-fpm.sock
        - target: /run/php/php{{ php_version }}-fpm.sock

    service.running:
        - name: php{{ php_version }}-fpm
        - enable: True
        - require:
            - file: php-fpm
            - file: php-fpm-config
            - php-fpm-pool
        - watch:
            - pkg: php-nginx-deps
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
