newrelic-infrastructure-configuration:
    file.managed:
        - name: /etc/newrelic-infra.yml
        - source: salt://elife/config/etc-newrelic-infra.yml
        - template: jinja
        - context:
            display_name: {{ salt['elife.cfg']('project.nodename', 'project.stackname', 'cfn.stack_id', 'Unknown server') }}
            project: {{ salt['elife.cfg']('project.project_name', 'Unknown project') }}
            environment: {{ salt['elife.cfg']('project.instance_id', 'Unknown environment') }}

newrelic-infrastructure-repository-key:
    cmd.run:
        - name: "curl https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | apt-key add -"

newrelic-infrastructure-repository:
    cmd.run:
        - name: "printf \"deb [arch=amd64] http://download.newrelic.com/infrastructure_agent/linux/apt {{ salt['grains.get']('oscodename') }} main\" | tee /etc/apt/sources.list.d/newrelic-infra.list"
        - require:
            - newrelic-infrastructure-repository-key

newrelic-infrastructure:
    pkg.installed:
        - name: newrelic-infra
        - refresh: True
        - require:
            - newrelic-infrastructure-repository
            - newrelic-infrastructure-configuration

    service.running:
        - name: newrelic-infra
        - enable: True
        - require:
            - pkg: newrelic-infrastructure
