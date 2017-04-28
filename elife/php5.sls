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

purge-old-php:
    pkg.purged:
        - pkgs:
            - php5
            - libapache2-mod-php5

php:
    pkg.installed:
        - pkgs:
            - php5.6
            - php5.6-dev
            #- php-pear
            - php5.6-mysql
            - php5.6-xsl
            - php5.6-gd
            - php5.6-curl
            - php5.6-mcrypt
            - php5.6-mbstring
            - libpcre3-dev # pcre for php5
            - libapache2-mod-php5.6
        - require:
            - purge-old-php

php5.6-apache-ini:
    file.managed:
        - name: /etc/php/5.6/apache2/php.ini
        - source: salt://elife/config/etc-php-5.6-apache2-php.ini
        - require:
            - pkg: php

php-log:
    file.managed:
        - name: /var/log/php_errors.log
        - user: {{ pillar.elife.webserver.username }}
        - mode: 640

# I'm not sure if this is even used ...
#pecl-uploadprogress:
#    cmd.run:
#        - name: pecl install uploadprogress
#        - unless:
#            - pecl list | grep uploadprogress
#        - require:
#            - pkg: php
