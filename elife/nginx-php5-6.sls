#
# bridges Nginx and PHP 5.6
# depends on elife/php-5-6-ubuntu-14-04.sls
# 

php-nginx-deps:
    pkg.installed:
        - name: php5-fpm

php-fpm-config:
    file.managed:
        - name: /etc/php5/fpm/php.ini
        - source: salt://elife/config/etc-php5-fpm-php.ini
        - require:
            - pkg: php-nginx-deps

php-fpm:
    # nginx config needs to target this sock file. 
    # easier to target when version stripped out
    file.symlink:
        - name: /var/php-fpm.sock
        - target: /run/php/php5-fpm.sock

    service.running:
        - name: php5-fpm
        - require:
            - file: php-fpm
            - file: php-fpm-config
