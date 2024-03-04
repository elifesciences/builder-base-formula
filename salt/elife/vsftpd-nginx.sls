vsftpd-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/vsftpd.conf
        - source: salt://elife/config/etc-nginx-sites-enabled-vsftpd.conf
        - template: jinja
        - listen_in:
            - service: nginx-server-service
