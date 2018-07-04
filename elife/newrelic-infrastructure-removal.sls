newrelic-infrastructure-configuration:
    file.absent:
        - name: /etc/newrelic-infra.yml

newrelic-infrastructure:
    pkg.purged:
        - name: newrelic-infra

    service.dead:
        - name: newrelic-infra
