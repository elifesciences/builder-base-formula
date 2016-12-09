newrelic-repository:
    cmd.run:
        - name: echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' > /etc/apt/sources.list.d/newrelic.list

newrelic-repository-key:
    cmd.run:
        - name: wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
        - unless:
            - apt-key list | grep 548C16BF


# this agent monitors CPU, RAM, IO, load...
newrelic-system-daemon-package:
    pkg.installed:
        - name: newrelic-sysmond
        - refresh: True
        - require:
            - newrelic-repository
            - newrelic-repository-key


newrelic-system-daemon-license:
    cmd.run:
        - name: nrsysmond-config --set license_key={{ pillar.elife.newrelic.license }}
        - require:
            - newrelic-system-daemon-package
        - unless:
            - grep license_key={{ pillar.elife.newrelic.license }} /etc/newrelic/nrsysmond.cfg

{% set newrelic_hostname = salt['elife.cfg']('project.nodename', 'project.stackname', 'cfn.stack_id', 'Unknown server') %}
newrelic-system-daemon-hostname:
    file.replace:
        - name: /etc/newrelic/nrsysmond.cfg
        - pattern: "^#?hostname=.*$"
        - repl: "hostname={{ newrelic_hostname }}"
        - require:
            - newrelic-system-daemon-package
        - unless:
            - grep hostname={{ newrelic_hostname }} /etc/newrelic/nrsysmond.cfg

{% newrelic_labels = salt['elife.cfg']('project.project_name', 'Unknown project') %}
newrelic-system-daemon-labels:
    file.replace:
        - name: /etc/newrelic/nrsysmond.cfg
        - pattern: "^#?labels=.*$"
        - repl: "labels=project:{{ newrelic_labels }},environment={{ salt['elife.cfg']('project.instance_id', 'Unknown environment') }}"
        - require: 
            - newrelic-system-daemon-package

newrelic-system-daemon:
    service.running:
        - name: newrelic-sysmond
        - require:
            - newrelic-system-daemon-license
            - newrelic-system-daemon-hostname
            - newrelic-system-daemon-labels
        - watch:
            - newrelic-system-daemon-license
            - newrelic-system-daemon-hostname
            - newrelic-system-daemon-labels
