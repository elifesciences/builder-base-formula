newrelic-php-extension-package:
    pkg.installed:
        # the package contains both PHP 5 and PHP 7 support
        # https://discuss.newrelic.com/t/php-agent-and-php-7-0/27687/85
        - name: newrelic-php5
        - require:
            - newrelic-system-daemon

newrelic-php-extension-headless-configuration:
    environ.setenv:
        - value:
            NR_INSTALL_SILENT: "set-any-value-to-enable"
            #NR_INSTALL_PATH: ...
            NR_INSTALL_KEY: "{{ pillar.elife.newrelic.license }}"

newrelic-install-script:
    cmd.run:
        - name: newrelic-install
        - require:
            - newrelic-php-extension-package
            - newrelic-php-extension-headless-configuration
