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
