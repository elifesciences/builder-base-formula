# only supports 16.04!

{% if pillar.elife.php.processes.enabled %}
{% for name, configuration in pillar.elife.php.processes.configuration.items() %}
{% set hyphenized = name | replace('_', '-') %}
{% set service_name = salt['elife.project_name']() + '-' + hyphenized %}
service-{{ hyphenized }}:
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
            {% if configuration.get('require', None) -%}
            - {{ configuration.get('require') }}
            {%- endif %}
        - require_in:
            - cmd: service-reload-configurations
{% endfor %}

service-reload-configurations:
    cmd.run:
        - name: systemctl daemon-reload

{% for name, configuration in pillar.elife.php.processes.configuration.items() %}
{% set hyphenized = name | replace('_', '-') %}
{% set service_name = salt['elife.project_name']() + '-' + hyphenized %}
{% for i in range(1, configuration['number'] + 1) %}
service-{{ hyphenized }}-{{ i }}-enable:
    cmd.run:
        - name: systemctl enable {{ service_name }}@{{ i }}
        - require:
            - service-{{ hyphenized }}
        - require_in:
            - file: service-{{ hyphenized }}-parallel-restart
{% endfor %}

# TODO: this could be a single command for all kinds of processes
service-{{ hyphenized }}-parallel-restart:
    cmd.run:
        - name: systemctl restart {{ service_name }}@{1..{{ configuration['number'] }}}
{% endfor %}
{% endif %}
