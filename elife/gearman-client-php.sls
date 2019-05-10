{% if salt['grains.get']('osrelease') == '14.04' %}
php-ppa-gearman:
    pkgrepo.managed:
        - humanname: Ondřej Surý PHP GEARMAN PPA
        - ppa: ondrej/pkg-gearman
        - keyserver: keyserver.ubuntu.com
        - file: /etc/apt/sources.list.d/ondrej-pkg-gearman.list
        - require:
            - php-ppa
            - php
        - unless:
            - test -e /etc/apt/sources.list.d/ondrej-pkg-gearman.list
        - onlyif:
            # we're using a third party ppa for php and need the separate ppa for gearman
            - test -e /etc/apt/sources.list.d/ondrej-php-trusty.list || test -e /etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list
            
{% else %}

# 16.04 above ppa is partially included in the php7 sls file
# it references php-gearman but does not include it's dependencies:
# * https://github.com/oerdnj/deb.sury.org/issues/711
# * https://www.patreon.com/posts/gearman-now-in-14627464
#
# the below, separate ppa, does include those requisites

php-ppa-gearman:
    pkgrepo.managed:
        - ppa: ondrej/pkg-gearman
        - key_text: 1024R/14AA40EC0831756756D7F66C4F4EA0AAE5267A6C
{% endif %}

gearman-php-extension:
    pkg.installed:
        - pkgs:
            - php-gearman
        - require:
            - php-ppa-gearman
