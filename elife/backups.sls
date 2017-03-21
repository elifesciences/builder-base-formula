install-ubr:
    # necessary because git.latest won't actually force anything in 2014.8
    cmd.run:
        - name: cd /opt/ubr && git reset --hard && git fetch
        - onlyif:
            - test -d /opt/ubr

    git.latest:
        - name: https://github.com/elifesciences/ubr
        - target: /opt/ubr
        - rev: master # what branch to clone
        - branch: master # and name of local branch to clone into.
        - force_checkout: True
        - require:
            - cmd: install-ubr

    file.managed:
        - name: /etc/ubr/config
        - source: salt://elife/config/etc-ubr-config
        - template: jinja
        - makedirs: True
        - require:
            - git: install-ubr

new-ubr-config:
    file.managed:
        - name: /opt/ubr/app.cfg
        - source: salt://elife/config/opt-ubr-app.cfg
        - template: jinja
        # read-write for root only
        - user: root
        - group: root
        - mode: 600
        - require:
            - install-ubr

# untested
#monitor-logs:
#    file.managed:
#        - name: /etc/syslog-ng/conf.d/ubr.conf
#        - source: salt://elife/config/etc-syslog-ng-conf.d-ubr.conf


daily-backups: # 11pm every day
{% if pillar.elife.dev %}
    cron.absent:
{% else %}
    cron.present:
{% endif %}
        - user: root
        - identifier: daily-app-backups
        - name: cd /opt/ubr/ && ./ubr.sh > /var/log/ubr-cron.log
        - minute: 0
        - hour: 23
        - require:
            - install-ubr
