# WARNING: this file cannot be included without specifying:
#
# - pillar.elife.newrelic_python.application_folder
#     path to a Python application with a venv/ folder inside
#
# - pillar.elife.newrelic_python.dependency_state
#     the name of a state that this configuration should be placed after
#
# - pillar.elife.newrelic_python.service 
#     the name of a service.running state that should be restarted

newrelic-python-license-configuration:
    cmd.run:
        - name: venv/bin/newrelic-admin generate-config {{ pillar.elife.newrelic.license }} newrelic.ini
        - cwd: {{ pillar.elife.newrelic_python.application_folder }}
        - user: {{ pillar.elife.deploy_user.username }}
        - unless:
            - grep -r {{ pillar.elife.newrelic.license }} newrelic.ini
        - require: 
            - {{ pillar.elife.newrelic_python.dependency_state }}

newrelic-python-ini-configuration-appname:
    file.replace:
        - name: {{ pillar.elife.newrelic_python.application_folder }}/newrelic.ini
        - pattern: '^app_name.*'
        - repl: app_name = {{ salt['elife.cfg']('project.stackname', 'cfn.stack_id', 'Python application') }}
        - require:
            - newrelic-python-license-configuration
        {% if pillar.elife.newrelic_python.service %}
        - listen_in:
            - service: {{ pillar.elife.newrelic_python.service }}
        {% endif %}

newrelic-python-logfile-agent-in-ini-configuration:
    file.replace:
        - name: {{ pillar.elife.newrelic_python.application_folder }}/newrelic.ini
        - pattern: '^#?log_file.*'
        - repl: log_file = stderr
        - require:
            - newrelic-python-license-configuration
        {% if pillar.elife.newrelic_python.service %}
        - listen_in:
            - service: {{ pillar.elife.newrelic_python.service }}
        {% endif %}

