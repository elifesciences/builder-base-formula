# requires both php7 and nginx-php7 state files

newrelic-php-extension-package:
    pkg.installed:
        # the package contains both PHP 5 and PHP 7 support
        # https://discuss.newrelic.com/t/php-agent-and-php-7-0/27687/85
        - name: newrelic-php5
        - require:
            - newrelic-system-daemon
            - php
            #- php-fpm-config

newrelic-php-extension-headless-configuration:
    environ.setenv:
        - value:
            NR_INSTALL_SILENT: "set-any-value-to-enable"
            #NR_INSTALL_PATH: ...
            NR_INSTALL_KEY: "{{ pillar.elife.newrelic.license }}"

newrelic-install-script:
    cmd.run:
        - name: newrelic-install install
        - require:
            - newrelic-php-extension-package
            - newrelic-php-extension-headless-configuration

{% for ini_file in ['/etc/php/5.6/apache2/conf.d/20-newrelic.ini', '/etc/php/5.6/cli/conf.d/20-newrelic.ini', '/etc/php/7.0/cli/conf.d/newrelic.ini', '/etc/php/7.0/fpm/conf.d/newrelic.ini'] %}
newrelic-ini-for-{{ ini_file }}:
    file.managed:
        - name: {{ ini_file }}
        - source: salt://elife/config/etc-php-7.0-sapi-conf.d-newrelic.ini
        - template: jinja
        - onlyif:
            - test -e {{ ini_file }}
        - require:
            - newrelic-install-script
        #- listen_in:
        #    - service: php-fpm

# remove when situation is stabilized
remove-old-newrelic-ini-for-{{ ini_file}}-backups:
    file.absent:
        - name: {{ ini_file }}.bak
        - require:
            - newrelic-ini-for-{{ ini_file }}
{% endfor %}

remove-additional-mods-available-file:
    file.absent:
        - name: /etc/php/7.0/mods-available/newrelic.ini
        - require:
            - newrelic-install-script

