newrelic-infrastructure:
    service.dead:
        - name: newrelic-infra

    pkg.purged:
        - name: newrelic-infra
        - require:
            - service: newrelic-infrastructure

newrelic-infrastructure-configuration:
    file.absent:
        - name: /etc/newrelic-infra.yml
