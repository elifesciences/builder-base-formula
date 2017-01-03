install-ubr:
    # necessary because git.latest won't actually force anything in 2014.8
    cmd.run:
        - name: cd /opt/ubr && git reset --hard
        - onlyif:
            - test -d /opt/ubr

    git.detached:
        - name: https://github.com/elifesciences/ubr
        - ref:  d1430c5585c60ade4f08347924190386e70cc493 # master, stable
        #- ref: 5be709277eab9e293f8ae552057198097a22a3c3 # develop, unstable
        - force_checkout: True
        - hard_reset: True        
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
