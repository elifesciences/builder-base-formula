old-ubr-config:
    file.absent:
        # this file now lives in /opt/ubr/app.cfg
        - name: /etc/ubr/config

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

new-ubr-config:
    file.managed:
        - name: /opt/ubr/app.cfg
        - source: salt://elife/config/opt-ubr-app.cfg
        - template: jinja
        - defaults:
            working_dir: /tmp
{% if salt['file.directory_exists' ]('/ext/tmp') %}
        - context:
            working_dir: /ext/tmp
{% endif %}
        # read-write for root only
        - user: root
        - group: root
        - mode: 600
        - require:
            - install-ubr

monitor-backup-logs:
    file.managed:
        - name: /etc/syslog-ng/conf.d/ubr.conf
        - source: salt://elife/config/etc-syslog-ng-conf.d-ubr.conf
        - template: jinja
        - require:
            - pkg: syslog-ng


# 11pm every day
daily-backups: 
    # only backup prod, adhoc and continuumtest instances
    {% if pillar.elife.env in ['dev', 'ci', 'end2end'] %}
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
