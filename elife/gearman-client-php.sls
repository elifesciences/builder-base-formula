php-ppa-gearman:
    pkgrepo.managed:
        - humanname: Ondřej Surý PHP GEARMAN PPA
        - ppa: ondrej/pkg-gearman
        - keyserver: keyserver.ubuntu.com
        - file: /etc/apt/sources.list.d/ondrej-pkg-gearman.list
        - require:
            - pkgrepo: php-ppa
            - php
        - unless:
            - test -e /etc/apt/sources.list.d/ondrej-pkg-gearman.list
        - onlyif:
            # we're using a third party ppa for php and need the separate ppa for gearman
            - test -e /etc/apt/sources.list.d/ondrej-php-trusty.list || test -e /etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list

gearman-php-extension:
    pkg.installed:
        - pkgs:
            - php-gearman
        - require:
            - php-ppa-gearman
