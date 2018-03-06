# apache + php7
# out of the box on 14.04 installing apache will also get you php-mod5
# this state file disables mod_php5, installs+enables mod_php7 and reloads apache

extend:
    apache2-php5-mod:
        cmd.run:
            - name: a2dismod php5.6

# install and enable mod_php7 for apache
apache-php7:
    pkg.installed:
        - pkgs:
            - libapache2-mod-php7.0
        - require:
            - php # php7.sls

    apache_module.enabled:
        - name: php7.0
        - require:
            - apache2-php5-mod # ensure mod php5 is disabled first
            - pkg: apache-php7
        - watch_in:
            - service: apache2-server
