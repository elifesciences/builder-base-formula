
{% if 
    salt['file.file_exists']('/etc/apt/sources.list.d/ondrej-php-trusty.list') or
    salt['file.file_exists']('/etc/apt/sources.list.d/ondrej-ubuntu-php-xenial.list')
%}

# we're using a third party ppa for php and need the separate ppa for gearman

php-ppa-gearman:
    pkgrepo.managed:
        - humanname: Ondřej Surý PHP GEARMAN PPA
        - ppa: ondrej/pkg-gearman
        - keyserver: keyserver.ubuntu.com
        - file: /etc/apt/sources.list.d/ondrej-pkg-gearman.list
        - require:
            - pkgrepo: php-ppa
        - require_in:
            - pkg: gearman-php-extension
        - unless:
            - test -e /etc/apt/sources.list.d/ondrej-pkg-gearman.list

{% endif %}

gearman-daemon:
    pkg.installed:
        - pkgs:
            - gearman-job-server
            - gearman-tools

# the default Upstart script is broken and ignores /etc/default/gearman
# https://bugs.launchpad.net/ubuntu/+source/gearmand/+bug/1260830/
# replacing would require an additional restart if we modify the configuration
# here, but projects perform the restart by themselves after *they* modify it
gearman-upstart-script:
    file.managed:
        - name: /etc/init/gearman-job-server.conf
        - source: salt://elife/config/etc-init-gearman-job-server.conf
        - require:
            - gearman-daemon

gearman-php-extension:
    pkg.installed:
        - pkgs:
            - php-gearman
        - require:
            - gearman-daemon
            - php
