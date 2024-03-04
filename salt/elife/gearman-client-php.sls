{% if salt['grains.get']('osrelease') == '18.04' %}

# pecl-gearman @ https://github.com/wcgallego/pecl-gearman does not support php7.4

gearman-php-extension:
    git.latest:
        - name: https://github.com/wcgallego/pecl-gearman
        - rev: gearman-2.0.5
        - branch: master
        - target: /opt/pecl-gearman
        - force_fetch: true
        - force_clone: true
        - force_reset: true
        - force_checkout: true

    pkg.installed:
        - pkgs:
            - libgearman-dev

    file.managed:
        - name: /etc/php/7.2/mods-available/gearman.ini
        - contents: extension=gearman.so
        - require:
            - php

    cmd.run:
        - cwd: /opt/pecl-gearman
        - name: |
            set -e
            phpize
            ./configure
            make -j$(nproc)
            make install
            phpenmod gearman
        - onchanges:
            - file: gearman-php-extension
            - git: gearman-php-extension
            - pkg: gearman-php-extension
            - php-dev
{% else %}

gearman-php-extension:
    git.latest:
        - name: https://github.com/php/pecl-networking-gearman
        - rev: gearman-2.1.0
        - branch: master
        - target: /opt/pecl-gearman
        - force_fetch: true
        - force_clone: true
        - force_reset: true
        - force_checkout: true

    pkg.installed:
        - pkgs:
            - libgearman-dev

    file.managed:
        - name: /etc/php/7.4/mods-available/gearman.ini
        - contents: extension=gearman.so
        - require:
            - php

    cmd.run:
        - cwd: /opt/pecl-gearman
        - name: |
            set -e
            phpize
            ./configure
            make -j$(nproc)
            make install
            phpenmod gearman
        - onchanges:
            - file: gearman-php-extension
            - git: gearman-php-extension
            - pkg: gearman-php-extension
            - php-dev

{% endif %}
