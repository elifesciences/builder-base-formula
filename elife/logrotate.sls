logrotate noise filterer:
    file.managed:
        - name: /usr/local/bin/logrotate_noise_filter.py
        - source: salt://elife/scripts/logrotate_noise_filter.py
        - mode: 755

custom daily logrotate script:
    file.managed:
        - name: /etc/cron.daily/logrotate
        - source: salt://elife/config/etc-cron.daily-logrotate
        - mode: 755
        - require:
            - base
            - logrotate noise filterer
