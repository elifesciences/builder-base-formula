newrelic-python-license-configuration:
    file.absent:
        - name: {{ pillar.elife.newrelic_python.application_folder }}/newrelic.ini
{% if pillar.elife.newrelic_python.service %}
        - listen_in:
            - service: {{ pillar.elife.newrelic_python.service }}
{% endif %}
