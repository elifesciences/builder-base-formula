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

{% if pillar.elife.newrelic.enabled %}
    {% if not pillar.elife.newrelic_python %}

newrelic_python misconfigured:
    cmd.run:
        - name: echo "pillar data misconfigured, could not find 'pillar.elife.newrelic_python'" && false

    {% else %}
newrelic-python-license-configuration:
    cmd.run:
        - name: venv/bin/newrelic-admin generate-config {{ pillar.elife.newrelic.license }} newrelic.ini
        - cwd: {{ pillar.elife.newrelic_python.application_folder }}
        - runas: {{ pillar.elife.deploy_user.username }}
        - unless:
            - grep -r {{ pillar.elife.newrelic.license }} newrelic.ini
        - require: 
            - {{ pillar.elife.newrelic_python.dependency_state }}

newrelic-python-ini-configuration-appname:
    file.replace:
        - name: {{ pillar.elife.newrelic_python.application_folder }}/newrelic.ini
        - pattern: '^app_name.*'
        - repl: app_name = {{ salt['elife.cfg']('project.stackname', 'cfn.stack_id', 'python-unknown-application') }}
        - require:
            - newrelic-python-license-configuration
        {% if pillar.elife.newrelic_python.service %}
        - listen_in:
            - service: {{ pillar.elife.newrelic_python.service }}
        {% endif %}

newrelic-python-ini-configuration-labels:
    file.line:
        - name: {{ pillar.elife.newrelic_python.application_folder }}/newrelic.ini
        - content: "labels = project:{{ salt['elife.cfg']('project.project_name', 'python-unknown-project') }};env:{{ pillar.elife.env }}"
        - mode: ensure
        - after: '\[newrelic\]'
        - require:
            - newrelic-python-ini-configuration-appname
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
    {% endif %}
{% endif %}
