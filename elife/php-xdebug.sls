xdebug-package:
    pkg.installed:
        - pkgs:
            - php-xdebug
        - require:
            - cmd: php

xdebug-disabled:
    cmd.run:
        - name: phpdismod xdebug
        - require:
            - pkg: xdebug-package
        - listen_in:
            - service: php-fpm
        - onlyif:
            - php -i | grep xdebug # 'php --rz Xdebug' still returns 0 when it isn't enabled

xdebug-config:
    file.managed:
        - name: /etc/php/mods-available/xdebug.ini
        - source: salt://elife/config/etc-php-mods-available-xdebug.ini
        - template: jinja
        - require:
            - pkg: xdebug-package
