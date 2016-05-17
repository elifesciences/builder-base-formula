# base php installation
# any minion that needs php gets all this

php-packages:
    pkg.installed:
        - pkgs:
            - php5
            - php5-dev
            - php-pear
            - php5-mysql
            - php5-xsl
            - php5-gd
            - php5-curl
            - php5-mcrypt
            - libpcre3-dev # pcre for php5
        - require:
            - pkg: base

php-ini:
    file.managed:
        - name: /etc/php5/apache2/php.ini
        - backup: minion
        - source: salt://elife/config/etc-php5-apache2-php.ini
        - require:
            - pkg: php-packages

php-log:
    file.managed:
        - name: /var/log/php_errors.log
        - user: {{ pillar.elife.webserver.username }}
        - mode: 640

# EXTENSIONS

uploadprogress:
    cmd.run:
        - name: "pecl install uploadprogress"
        - unless:
            - pecl list | grep uploadprogress
        - require:
            - pkg: php-packages
