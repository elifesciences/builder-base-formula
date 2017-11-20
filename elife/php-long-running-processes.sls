# only supports 16.04!

{% for name, configuration in pillar.elife.php.processes.items() %}
php-long-running-process-service-{{ name }}:
    file.managed:
        - name: /lib/systemd/system/{{ salt['elife.project_name']() }}-{{ name }}.service
        - source: salt://elife/config/lib-systemd-system-php-service.service
        - template: jinja
        - context:
            name: {{ name }}
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
