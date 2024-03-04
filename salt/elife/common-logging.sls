rotate-salt-highstate-logs:
    file.managed:
        - name: /etc/logrotate.d/salt-highstate
        - source: salt://elife/config/etc-logrotate.d-salt-highstate
        - require:
            - base
