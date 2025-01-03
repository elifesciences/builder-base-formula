# prevent brute-force logins
fail2ban:
    pkg:
        - installed

    service.running:
        - require:
            - pkg: fail2ban

sudo_config:
    file.managed:
        - name: /etc/sudoers
        - source: salt://elife/config/etc-sudoers

    cmd.run:
        - name: sudo -k # 'restarts' sudo (invalidates sessions)
        - onchanges:
            - file: sudo_config

# disable root login
# disable password logins
sshd_config:
    file.managed:
        - name: /etc/ssh/sshd_config
        - source: salt://elife/config/etc-ssh-sshd_config

sshd:
    service.running:
        - enable: True
        - reload: True
        - watch:
            - file: /etc/ssh/sshd_config

# have the system keep itself updated with security patches in non-dev environments.
# lsh@2024-01-16: disabled in dev because work is often paused while dpkg is locked.
unattended-upgrades:
{% if pillar.elife.env == "dev" %}
    pkg.purged:
        - name: unattended-upgrades

    file.absent:
        - name: /etc/apt/apt.conf.d/10periodic
{% else %}
    pkg.installed:
        - name: unattended-upgrades

    file.managed:
        - name: /etc/apt/apt.conf.d/10periodic
        - source: salt://elife/config/etc-apt-apt.conf.d-10periodic
{% endif %}

unattended-upgrades-config:
{% if pillar.elife.env == "dev" %}
    file.absent:
        - name: /etc/apt/apt.conf.d/50unattended-upgrades
{% else %}
    file.managed:
        - name: /etc/apt/apt.conf.d/50unattended-upgrades
        - source: salt://elife/config/etc-apt-apt.conf.d-50unattended-upgrades
        - require:
            - file: unattended-upgrades
{% endif %}
