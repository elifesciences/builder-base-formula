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

{% set composer_home = '/usr/lib/composer' %}

composer-home-dir:
    file.directory:
        - name: {{ composer_home }}
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - dir_mode: 755
        - recurse:
            - user
            - group

composer-home-dir-cache:
    file.directory:
        - name: {{ composer_home }}/cache
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - dir_mode: 755
        - recurse:
            - user
            - group

composer-home:
    environ.setenv:
        - name: COMPOSER_HOME
        - value: {{ composer_home }}
        - require:
            - file: composer-home-dir
    file.managed:
        - name: /etc/profile.d/composer-home.sh
        - contents: export COMPOSER_HOME={{ composer_home }}
        - require:
            - composer-home-dir
            - composer-home-dir-cache

{% if pillar.elife.projects_builder.github_token %}
composer-auth:
    builder.environ_setenv_sensitive:
        - name: COMPOSER_AUTH
        - value: '{"github-oauth": { "github.com": "{{ pillar.elife.projects_builder.github_token }}" } }'
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
            - composer-home
            - composer-auth
        - unless:
            - which composer

composer-global-paths:
    file.managed:
        - name: /etc/profile.d/composer-global-paths.sh
        - contents: export PATH={{ composer_home }}/vendor/bin:$PATH
        - require:
            - file: composer-home-dir

update-composer:
    cmd.run:
        - name: composer self-update
        - onlyif:
            - which composer
        - require:
            - cmd: install-composer

# useful to depend on
composer:
    cmd.run:
        - name: composer --version
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - update-composer
            - composer-global-paths
