gearman-daemon:
    pkg.installed:
        - pkgs:
            - gearman-job-server

gearman-php-extension:
    pkg.installed:
        - pkgs:
            - php7.0-gearman
        - require:
            - gearman-daemon
            - php
