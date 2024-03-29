# run the 'salt-call state.highstate' command once a day to bring the machine
# in-line with it's configuration. removes uncertainty, stops pesky tinkerers.

# environments that are typically in a stopped state have their daily updates 
# managed by Jenkins

{% set environments_managed_through_alfred = ['ci', 'end2end', 'demo'] %}
{% set crontab = pillar.elife.daily_system_updates %}

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
    {% if crontab.enabled and not pillar.elife.env in environments_managed_through_alfred %}
    cron.present:
        - identifier: daily-system-update
        - name: /usr/local/bin/daily-system-update
        # stagger updates to so clusters don't step on each other and the salt-master isn't overwhelmed.
        - minute: {% if crontab.minute == 'random' %}{{ range(0,59)|random }}{% else %}{{ crontab.minute }}{% endif %}
        - hour: {{ crontab.hour }}
        - dayweek: {{ crontab.dayweek }}
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


{% if not crontab.enabled or pillar.elife.env in environments_managed_through_alfred %}
# unattended upgrades
# managed through Alfred
daily-security-updates-cron-disable:
    file.absent:
        - name: /etc/cron.daily/apt-compat

{% if salt['grains.get']('osrelease') != "14.04" %}
# introduced in 16.04, this service performs various APT-related tasks like refreshing the list 
# of available packages, performing unattended upgrades if needed, etc.
systemd-unattended-upgrades-disable:
    cmd.run:
        - name: |
            systemctl disable apt-daily.timer
            systemctl disable apt-daily-upgrade.timer
{% endif %}
{% endif %}
