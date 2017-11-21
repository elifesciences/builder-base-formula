# only supports 16.04!

{% if pillar.elife.php.processes.enabled %}
{% for name, configuration in pillar.elife.php.processes.configuration.items() %}
{% set hyphenized = name | replace("_", "-") %}
{% set service_name = salt['elife.project_name']() + "-" + hyphenized %}
php-long-running-process-service-{{ hyphenized }}:
    file.managed:
        - name: /lib/systemd/system/{{ service_name }}@.service
        - source: salt://elife/config/lib-systemd-system-php-service.service
        - template: jinja
        - context:
            name: {{ hyphenized }}
            folder: {{ configuration.folder }}
            command: {{ configuration.command }}
        - require:
            - php
            # TODO: add optional require
        - require_in:
            - cmd: php-long-running-processes-load-configuration
{% endfor %}

php-long-running-processes-load-configuration:
    cmd.run:
        - name: systemctl daemon-reload

{% for name, configuration in pillar.elife.php.processes.configuration.items() %}
{% set hyphenized = name | replace("_", "-") %}
{% set service_name = salt['elife.project_name']() + "-" + hyphenized %}
# TODO: " vs '
{% for i in range(1, configuration['number'] + 1) %}
php-long-running-process-service-{{ hyphenized }}-{{ i }}-start:
    cmd.run:
        - name: systemctl enable {{ service_name }}@{{ i }}
        - require:
            - php-long-running-process-service-{{ hyphenized }}
        - require_in:
            - file: php-long-running-process-service-{{ hyphenized }}-parallel-restart
{% endfor %}

# TODO: this could be a single command for all kinds of processes
php-long-running-process-service-{{ hyphenized }}-parallel-restart:
    file.managed:
        - name: /usr/local/bin/php-long-running-processes-{{ hyphenized }}-restart
        - source: salt://elife/templates/systemd-multiple-processes.sh
        - template: jinja
        - mode: 544
        - context:
            process: {{ service_name }}
            number: {{ configuration['number'] }}

    cmd.run:
        - name: php-long-running-processes-{{ hyphenized }}-restart
        - require:
            - file: php-long-running-process-service-{{ hyphenized }}-parallel-restart

{% endfor %}

    
{% endif %}
