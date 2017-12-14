# run the 'salt-call state.highstate' command once a day to bring the machine
# in-line with it's configuration. removes uncertainty, stops pesky tinkerers.

daily-system-update-command:
    file.managed:
        - name: /usr/local/bin/daily-system-update
        - source: salt://elife/config/usr-local-bin-daily-system-update
        - mode: 544

daily-security-updates-command:
    file.managed:
        - name: /usr/local/bin/daily-security-update
        - source: salt://elife/config/usr-local-bin-daily-security-update
        - mode: 544

daily-system-update-log-rotater:
    file.managed:
        - name: /etc/logrotate.d/daily-system-update
        - source: salt://elife/config/etc-logrotate.d-daily-system-update

daily-system-updates:
    {% if not pillar.elife.env in ['ci', 'end2end'] %}
    cron.present:
        - identifier: daily-system-update
        - name: /usr/local/bin/daily-system-update
        # stagger updates to clusters of machines
        {% if salt['elife.cfg']('project.node', 1) % 2 == 1 %}
        # odd server
        - minute: '15'
        {% else %}
        # even server
        - minute: '45'
        {% endif %}
        - hour: 21
        - dayweek: '0-4'
        - require:
            - file: daily-system-update-log-rotater
            - daily-system-update-command
       # don't update vagrant machines
        - onlyif:
            - test ! -d /vagrant
    {% else %}
    # managed through Alfred
    cron.absent:
        - identifier: daily-system-update
        - name: /usr/local/bin/daily-system-update
    {% endif %}


{% if pillar.elife.env in ['ci', 'end2end'] %}
# managed through Alfred
daily-security-updates-cron-disable:
    file.absent:
        - name: /etc/cron.daily/apt-compat
{% endif %}

