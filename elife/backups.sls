install-ubr:
    # necessary because git.latest won't actually force anything in 2014.8
    cmd.run:
        - name: cd /opt/ubr && git reset --hard
        - onlyif:
            - test -d /opt/ubr

    git.latest:
        - name: https://github.com/elifesciences/ubr
        # these work in 2015.8.0
        - force: True
        - force_checkout: True
        - force_reset: True        
        - target: /opt/ubr
        - require:
            - cmd: install-ubr

    file.managed:
        - name: /etc/ubr/config
        - source: salt://elife/config/etc-ubr-config
        - template: jinja
        - makedirs: True
        - require:
            - git: install-ubr


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
            - git: install-ubr
