# apache + php7
# out of the box on 14.04 installing apache will also get you php-mod5
# this state file disables mod_php5, installs+enables mod_php7 and reloads apache

{% set php_version = '7.2' %}
{% if salt['grains.get']('osrelease') in ["14.04", "16.04"] %}
{% set php_version = '7.0' %}
{% endif %}

extend:
    apache2-php5-mod:
        cmd.run:
            - name: a2dismod php5.6
            - onlyif:
                # mod_php for 5.6 is available
                - test -e /etc/apache2/mods-available/php5.6.conf

# install and enable mod_php7 for apache
apache-php7:
    pkg.installed:
        - pkgs:
            - libapache2-mod-php{{ php_version }}
        - require:
            - php # php7.sls

    apache_module.enabled:
        - name: php{{ php_version }}
        - require:
            - apache2-php5-mod # ensure mod php5 is disabled first
            - pkg: apache-php7
        - watch_in:
            - service: apache2-server
