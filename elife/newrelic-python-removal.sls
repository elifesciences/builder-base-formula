newrelic-python-license-configuration:
    file.absent:
        - name: {{ pillar.elife.newrelic_python.application_folder }}/newrelic.ini
        - listen_in:
            - service: {{ pillar.elife.newrelic_python.service }}
