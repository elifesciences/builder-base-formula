# base php installation

php-ppa:
    cmd.run:
        - name: apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

    pkgrepo.managed:
        - humanname: Ondřej Surý PHP PPA
        # there was a name change from "php-7.0" to just "php"
        - ppa: ondrej/php
        - require:
            - cmd: php-ppa
            #- pkgrepo: old-php-ppa

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
        - require:
            - php
            - php-log


#
# Composer (php package management)
#

{% set composer_home = '/home/' ~ pillar.elife.deploy_user.username ~ '/.composer' %}

composer-home:
    environ.setenv:
        - name: COMPOSER_HOME
        - value: {{ composer_home }}
    cmd.run:
        - name: echo 'export COMPOSER_HOME={{ composer_home }}' > /etc/profile.d/composer-home.sh
        - require:
            - environ: composer-home

{% if pillar.elife.deploy_user.github_token %}
composer-auth:
    builder.environ_setenv_sensitive:
        - name: COMPOSER_AUTH
        - value: '{"github-oauth": { "github.com": "{{ pillar.elife.deploy_user.github_token }}" } }'
{% else %}
composer-auth:
    environ.setenv:
        - name: COMPOSER_AUTH
        - value: ''
{% endif %}

install-composer:
    cmd.run:
        - cwd: /usr/local/bin/
        - name: |
            wget -O - https://getcomposer.org/installer | php
            mv composer.phar composer
        - require:
            - php
            - environ: composer-home
            - composer-auth
        - unless:
            - which composer

composer-global-paths:
    cmd.run:
        - name: echo 'export PATH={{ composer_home }}/vendor/bin:$PATH' > /etc/profile.d/composer-global-paths.sh
        - require:
            - cmd: install-composer

update-composer:
    cmd.run:
        - name: composer self-update
        - onlyif:
            - which composer
        - require:
            - cmd: install-composer

composer-permissions:
    file.directory:
        - name: {{ composer_home }}
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - cmd: update-composer

composer-cache-dir:
    cmd.run:
        - name: composer global config cache-dir /tmp/composer-cache
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - composer-permissions

# useful to depend on
composer:
    cmd.run:
        - name: composer --version
        - require:
            - composer-permissions
            - composer-global-paths
            - composer-cache-dir
        
