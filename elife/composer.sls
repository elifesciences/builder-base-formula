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

# https://getcomposer.org/doc/03-cli.md#composer-auth
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
    file.managed:
        - name: {{ composer_home }}/setup.php
        - source: https://getcomposer.org/installer
        - source_hash: https://composer.github.io/installer.sig
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - composer-home
        - unless:
            - which composer
    cmd.run:
        - cwd: {{ composer_home }}
        - name: php setup.php --install-dir=/usr/local/bin --filename=composer
        - require:
            - php
            - file: install-composer
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
