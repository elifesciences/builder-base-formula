# run the 'salt-call state.highstate' command once a day to bring the machine
# in-line with it's configuration. removes uncertainty, stops pesky tinkerers.

daily-system-update-command:
    file.managed:
        - name: /usr/local/bin/daily-system-update
        - source: salt://elife/config/usr-local-bin-daily-system-update
        - mode: 544

daily-system-update-log-rotater:
    file.managed:
        - name: /etc/logrotate.d/daily-system-update
        - source: salt://elife/config/etc-logrotate.d-daily-system-update

# every weekday at 10:30am UTC
daily-system-updates:
    cron.present:
        - identifier: daily-system-update
        # salt isn't emitting anything :( this log and logrotation is useless
        - name: /usr/local/bin/daily-system-update
        - minute: 30
        - hour: 10
        - dayweek: '1-5'
        - require:
            - file: daily-system-update-log-rotater
            - daily-system-update-command
