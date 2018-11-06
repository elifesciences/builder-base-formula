custom daily logrotate script:
    file.managed:
        - name: /etc/cron.daily/logrotate
        - source: salt://elife/config/etc-cron.daily-logrotate
        - mode: 755
        - require:
            - base
