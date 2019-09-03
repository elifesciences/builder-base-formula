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

gearman-php-extension:
    pkg.installed:
        - pkgs:
            - php-gearman

{% elif salt['grains.get']('osrelease') == '16.04' %}

# the ppa in the php7 sls file references php-gearman but does not
# include php-gearman's dependencies:
# * https://github.com/oerdnj/deb.sury.org/issues/711
# * https://www.patreon.com/posts/gearman-now-in-14627464
#
# the below ppa *does* include those requisites but has no 18.04 version
# possibly because php-gearman is available natively in 18.04:
# * https://packages.ubuntu.com/bionic/php-gearman

php-ppa-gearman:
    cmd.run:
        - name: |
            # will successfully install key but also fails (on 16.04 only) with
            # "'ascii' codec can't decode byte 0xc5 in position 92: ordinal not in range(128)"
            # this is a Ubuntu problem, not Salt
            apt-add-repository -y ppa:ondrej/pkg-gearman
            apt-get update
        - unless:
            - test -e /etc/apt/sources.list.d/ondrej-ubuntu-pkg-gearman-xenial.list
        - require_in:
            - pkg: gearman-php-extension

gearman-php-extension:
    pkg.installed:
        - pkgs:
            - php-gearman

{% elif salt['grains.get']('osrelease') == '18.04' %}

php-ppa-gearman:
    pkg.purged:
        - pkgs:
            - php-gearman
        - require_in:
            - gearman-php-extension

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
