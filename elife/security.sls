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

    cmd.wait:
        - name: sudo -k # 'restarts' sudo (invalidates sessions)
        - watch:
            - file: sudo_config


# disable root login
# disable password logins  
sshd_config:
    file.managed:
        - name: /etc/ssh/sshd_config
        - source: salt://elife/config/etc-ssh-sshd_config
# this shouldn't kick the provisioning user but it does
#        - watch_in:
#            - service: ssh


# have the system keep itself updated with security patches
unattended-upgrades:
    pkg-installed:
        - name: unattended-upgrades

    file.managed:
        - name: /etc/apt/apt.conf.d/10periodic
        - source: salt://elife/config/etc-apt-apt.conf.d-10periodic

unattended-upgrades-config:
    file.managed:
        - name: /etc/apt/apt.conf.d/50unattended-upgrades
        - source: salt://elife/config/etc-apt-apt.conf.d-50unattended-upgrades
        - require:
            - file: unattended-upgrades
