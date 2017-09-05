# requires both php7 and nginx-php7 state files

newrelic-repository:
    file.managed:
        - name: /etc/apt/sources.list.d/newrelic.list
        - contents: |
            deb http://apt.newrelic.com/debian/ newrelic non-free

newrelic-repository-key:
    cmd.run:
        - name: wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
        - unless:
            - apt-key list | grep 548C16BF

newrelic-php-extension-package:
    pkg.installed:
        # the package contains both PHP 5 and PHP 7 support
        # https://discuss.newrelic.com/t/php-agent-and-php-7-0/27687/85
        - name: newrelic-php5
        - refresh: True
        - require:
            - newrelic-repository
            - newrelic-repository-key
            - php
            #- php-fpm-config

#newrelic-php-extension-headless-configuration:
#    environ.setenv:
#        - value:
#            NR_INSTALL_SILENT: "set-any-value-to-enable"
#            #NR_INSTALL_PATH: ...
#            NR_INSTALL_KEY: "{{ pillar.elife.newrelic.license }}"

newrelic-install-script:
    cmd.run:
        - name: newrelic-install install && touch /root/newrelic-installed-2017-04-11.flag
        - env:
            - NR_INSTALL_SILENT: "set-any-value-to-enable"
            - NR_INSTALL_KEY: "{{ pillar.elife.newrelic.license }}"
        - creates: /root/newrelic-installed-2017-04-11.flag
        - require:
            - newrelic-php-extension-package
            #- newrelic-php-extension-headless-configuration

{% for ini_file in ['/etc/php/5.6/apache2/conf.d/newrelic.ini', '/etc/php/5.6/cli/conf.d/newrelic.ini', '/etc/php/7.0/cli/conf.d/newrelic.ini', '/etc/php/7.0/fpm/conf.d/newrelic.ini'] %}
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

{% for ver in ['5.6', '7.0'] %}
remove-php{{ ver }}-newrelic-mods-available-file:
    file.absent:
        - name: /etc/php/{{ ver }}/mods-available/newrelic.ini
        - require:
            - newrelic-install-script
{% endfor %}
