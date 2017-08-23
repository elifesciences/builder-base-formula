newrelic-infrastructure-license:
    cmd.run:
        - name: "printf \"license_key: {{ pillar.elife.newrelic.license }}\" | tee -a /etc/newrelic-infra.yml"

{% set newrelic_hostname = salt['elife.cfg']('project.nodename', 'project.stackname', 'cfn.stack_id', 'Unknown server') %}
newrelic-infrastructure-display-name:
    cmd.run:
        - name: "printf \"display_name: {{ newrelic_hostname }}\" | tee -a /etc/newrelic-infra.yml"

{% set newrelic_project = salt['elife.cfg']('project.project_name', 'Unknown project') %}
{% set newrelic_environment = salt['elife.cfg']('project.instance_id', 'Unknown environment') %}
newrelic-infrastructure-custom-attributes:
    cmd.run:
        - name: "printf \"custom_attributes:\n  project: {{ newrelic_project }}\n  environment: {{ newrelic_environnment }}\" | tee -a /etc/newrelic-infra.yml"

newrelic-infrastructure-repository-key:
    cmd.run:
        - name: "curl https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | apt-key add -"

newrelic-infrastructure-repository:
    cmd.run:
        - name: "printf "\deb [arch=amd64] http://download.newrelic.com/infrastructure_agent/linux/apt {{ salt['grains.get']('oscodename') }} main\" | tee /etc/apt/sources.list.d/newrelic-infra.list"
        - require:
            - newrelic-infrastructure-repository-key

newrelic-infrastructure-package:
    pkg.installed:
        - name: newrelic-infra
        - refresh: True
        - require:
            - newrelic-infrastructure-repository
            - newrelic-infrastructure-license
            - newrelic-infrastructure-display-name
            - newrelic-infrastructure-custom-attributes
