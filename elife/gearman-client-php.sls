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
        - require_in:
            - pkg: gearman-php-extension
        - unless:
            - test -e /etc/apt/sources.list.d/ondrej-pkg-gearman.list
        - onlyif:
            # we're using a third party ppa for php and need the separate ppa for gearman
            - test -e /etc/apt/sources.list.d/ondrej-php-trusty.list || test -e /etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list
            
{% elif salt['grains.get']('osrelease') == '16.04' %}

# the above ppa is partially included in the ppa in the php7 sls file
# that ppa references php-gearman but does not include it's dependencies:
# * https://github.com/oerdnj/deb.sury.org/issues/711
# * https://www.patreon.com/posts/gearman-now-in-14627464
#
# the below ppa *does* include those requisites but has no 18.04 version
# possibly because php-gearman is available natively in 18.04:
# * https://packages.ubuntu.com/bionic/php-gearman

php-ppa-gearman:
    pkgrepo.managed:
        - ppa: ondrej/pkg-gearman
        - key_text: 1024R/14AA40EC0831756756D7F66C4F4EA0AAE5267A6C
        - require_in:
            - pkg: gearman-php-extension
{% endif %}

gearman-php-extension:
    pkg.installed:
        - pkgs:
            - php-gearman
