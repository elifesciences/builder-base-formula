logrotate service file:
    file.managed:
        - name: /lib/systemd/system/logrotate.service
        - source: salt://elife/config/lib-systemd-system-logrotate.service
        - mode: 644
        - require:
            - pkg: base

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

# not necessary, logrotate is activated by `logrotate.timer` ...
#logrotate service:
#    service.running:
#        - name: logrotate

# ... however this seems to ensure daemon-reload is called on any changes to the service file.
# (even though it marks the state as having no changes)
logrotate service:
    service.enabled:
        - name: logrotate
        - require:
            - logrotate service file
            - custom daily logrotate script
