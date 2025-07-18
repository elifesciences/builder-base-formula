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

    file.directory:
        - name: /etc/ubr/
        - makedirs: True

mise-trust-ubr:
    cmd.run:
        - name: cd /opt/ubr &&  mise trust
        - require:
            - install-ubr

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

rotate-backup-logs:
    file.managed:
        - name: /etc/logrotate.d/ubr
        - source: salt://elife/config/etc-logrotate.d-ubr
