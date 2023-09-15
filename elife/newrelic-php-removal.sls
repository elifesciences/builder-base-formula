newrelic-install-script:
    cmd.run:
        - name: newrelic-install purge || true

newrelic-install-script-flag:
    file.absent:
        - name: /root/newrelic-installed-2017-04-11.flag

newrelic-repository:
    file.absent:
        - name: /etc/apt/sources.list.d/newrelic.list
        - require:
            - newrelic-install-script

newrelic-php-extension-package:
    pkg.purged:
        - name: newrelic-php5
        - require:
            - newrelic-install-script

{% set php_version = '7.4' %}

{% for ini_file in ['/etc/php/' + php_version + '/cli/conf.d/newrelic.ini', '/etc/php/' + php_version + '/fpm/conf.d/newrelic.ini'] %}
newrelic-ini-for-{{ ini_file }}:
    file.absent:
        - name: {{ ini_file }}

remove-old-newrelic-ini-for-{{ ini_file}}-backups:
    file.absent:
        - name: {{ ini_file }}.bak
{% endfor %}

{% for ver in ['5.6', '7.0'] %}
remove-php{{ ver }}-newrelic-mods-available-file:
    file.absent:
        - name: /etc/php/{{ ver }}/mods-available/newrelic.ini
{% endfor %}
