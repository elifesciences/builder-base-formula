upstart-monitoring-script:
    file.managed:
        - name: /usr/local/bin/upstart-monitoring.sh
        - source: salt://elife/config/usr-local-bin-upstart-monitoring.sh
        - mode: 755

upstart-monitoring-log:
    file.managed:
        - name: /var/log/upstart-monitoring.log
        - mode: 666
        - replace: False
