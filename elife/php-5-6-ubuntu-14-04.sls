# base php installation
# any minion that needs php gets all this


php56-ppa:
    cmd.run:
        - name: apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

    pkgrepo.managed:
        - humanname: Ondřej Surý PHP 5.6 PPA
        - ppa: ondrej/php5-5.6
        - require:
            - cmd: php56-ppa # TODO keyserver/keyid don't appear to be working, so currently running the command manually.

php56:
    cmd.run:
        # here be dragons:
        # https://bugs.launchpad.net/ubuntu/+source/apt/+bug/423071
        # simply put: there are four possible dependencies and apache is the 
        # default. if you don't specify any of the others, INSTALLING PHP5 WILL 
        # INSTALL APACHE2
        - name: |
            export DEBIAN_FRONTEND=noninteractive 
            apt-get install -y --force-yes --no-install-recommends \
                php5 \
                php5-fpm \
                php5-dev \
                php-pear \
                php5-mysql \
                php5-xsl \
                php5-gd \
                php5-curl \
                php5-mcrypt \
                libpcre3-dev # pcre for php5 \
        - require:
            - pkgrepo: php56-ppa

php-packages:
    pkg.installed:
        - pkgs:
            - php5
#            - php5-dev
#            - php-pear
#            - php5-mysql
#            - php5-xsl
#            - php5-gd
#            - php5-curl
#            - php5-mcrypt
#            - libpcre3-dev # pcre for php5
        - require:
            - pkg: base
            - cmd: php56

php-log:
    file.managed:
        - name: /var/log/php_errors.log
        - user: {{ pillar.elife.webserver.username }}
        - mode: 640

pecl-uploadprogress:
    cmd.run:
        - name: pecl install uploadprogress
        - unless:
            - pecl list | grep uploadprogress
        - require:
            - pkg: php-packages
