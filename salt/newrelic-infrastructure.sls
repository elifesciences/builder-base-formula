newrelic-infrastructure-license:
    cmd.run:
        - name: printf "license_key: {{ pillar.elife.newrelic.license}}" | tee -a /etc/newrelic-infra.yml

newrelic-infrastructure-repository-key:
    cmd.run:
        - name: curl https://download.newrelic.com/infrastructure_agent/gpg/newrelic-infra.gpg | apt-key add -

newrelic-infrastructure-repository:
    cmd.run:
        - name: printf "deb http://download.newrelic.com/infrastructure_agent/linux/apt trusty main" | sudo tee -a /etc/apt/sources.list.d/newrelic-infra.list
        - require:
            - newrelic-infrastructure-repository-key
        
newrelic-infrastructure-package:
    pkg.installed:
        - name: newrelic-infra
        - refresh: True
        - require:
            - newrelic-infrastructure-repository
            - newrelic-infrastructure-license
