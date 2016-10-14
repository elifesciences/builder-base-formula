# requires both php7 and nginx-php7 state files

newrelic-php-extension-package:
    pkg.installed:
        # the package contains both PHP 5 and PHP 7 support
        # https://discuss.newrelic.com/t/php-agent-and-php-7-0/27687/85
        - name: newrelic-php5
        - require:
            - newrelic-system-daemon
            - php
            - php-fpm-config

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

{% for ini_file in ['/etc/php/7.0/cli/conf.d/newrelic.ini', '/etc/php/7.0/fpm/conf.d/newrelic.ini']
newrelic-ini:
    file.replace:
        - name: {{ ini_file }}
        - pattern: '^newrelic.appname'
        - repl: newrelic.appname = "{{ salt['elife.cfg']('project.instance_id') }}"
        - onlyif:
            - test -e {{ ini_file }}
        - require:
            - newrelic-install-script
        - listen_in:
            - service: php-fpm
