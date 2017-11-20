# only supports 16.04!

{% if pillar.elife.php.processes.enabled %}
{% for name, configuration in pillar.elife.php.processes.configuration.items() %}
{% set hyphenized = name | replace("_", "-") %}
{% set service_name = salt['elife.project_name']() + "-" + hyphenized %}
php-long-running-process-service-{{ name }}:
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
        - require_in:
            - cmd: php-long-running-processes
{% endfor %}

php-long-running-processes:
    cmd.run:
        - name: systemctl daemon-reload

{% for name, configuration in pillar.elife.php.processes.configuration.items() %}
{% set hyphenized = name | replace("_", "-") %}
{% set service_name = salt['elife.project_name']() + "-" + hyphenized %}
# TODO: add counter and instance numbers
# TODO: " vs '
{% for i in range(0, configuration['number']) %}
php-long-running-process-service-{{ name }}-{{ i }}-start:
    cmd.run:
        - name: systemctl enable {{ service_name }}@{{ i }}
        - require:
            - php-long-running-process-service-{{ name }}
        - require_in:
            - file: php-long-running-process-service-{{ name }}-parallel-restart
{% endfor %}

# TODO: this could be a single command for all kinds of processes
php-long-running-process-service-{{ name }}-parallel-restart:
    file.managed:
        - name: /usr/local/bin/php-long-running-processes-{{ name }}-restart
        - template: salt://elife/templates/systemd-multiple-processes.sh
        - mode: 544
        - context:
            process: {{ service_name }}
            number: {{ configuration['number'] }}

    cmd.run:
        - name: php-long-running-processes-{{ name }}-restart
        - require:
            - file: php-long-running-process-service-{{ name }}-parallel-restart

{% endfor %}

    
{% endif %}
