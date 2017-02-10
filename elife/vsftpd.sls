vsftpd-server:
    pkg.installed:
        - pkgs:
            - vsftpd 

vsftpd-configuration:
    file.managed:
        - name: /etc/vsftpd.conf
        - source: salt://elife/config/etc-vsftpd.conf
        - require:
            - vsftpd-server

vsftpd-service:
    service.running:
        - name: vsftpd
        - refresh: True
        - watch:
            - vsftpd-configuration

# TODO: add users with pillar
{% for user, info in pillar.elife.ftp_users.iteritems() %}
create-ftp-user-{{ user }}:
    user.present: 
        - name: {{ info.username }}
        - password: {{ info.password }}
        - shell: /bin/bash
{% endfor %}
