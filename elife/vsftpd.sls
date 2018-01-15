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

{% for user, info in pillar.elife.ftp_users.iteritems() %}
# https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-16-04
create-ftp-user-{{ user }}:
    user.present: 
        - name: {{ info.username }}
        - password: {{ info.password }}
        - shell: /bin/bash

    file.directory:
        - name: /home/{{ info.username }}/ftp
        - user: nobody
        - group: nogroup
        - mode: 555

create-ftp-upload-folder-user-{{ user }}:
    file.directory:
        - name: /home/{{ info.username }}/ftp/files
        - user: {{ info.username }}
        - group: {{ info.username }}
        - mode: 755
        - require: 
            - create-ftp-user-{{ user }}
{% endfor %}
