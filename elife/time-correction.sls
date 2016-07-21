ntpdate:
    pkg.installed

# once a day
system-time-drift-correction:
    cron.present:
        - identifier: system-time-drift-correction
        # 'ntpdate' comes with 'ntpdate-debian' which is identical except it 
        # uses a config file at /etc/default/ntpdate. the defaults are sensible.
        - name: /usr/sbin/ntpdate-debian
        - special: '@daily'
        - require:
            - pkg: ntpdate
