#
# make postfix relay mail through AWS SES
#

postfix-ses-password:
    file.managed:
        - name: /etc/postfix/relay_password
        - source: salt://elife/config/etc-postfix-relay_password
        - template: jinja
        - mode: 600
        - require:
            - pkg: postfix-mailserver

hash-postfix-password:
    cmd.run:
        - name: postmap /etc/postfix/relay_password
        - require:
            - file: postfix-ses-password

postfix-ses-config:
    file.managed:
        - name: /etc/postfix/main.cf
        - source: salt://elife/config/etc-postfix-main.cf
        - template: jinja
        - backup: minion
        - require:
            - pkg: postfix-mailserver
            - cmd: hash-postfix-password
        - watch_in:
            - service: postfix-mailserver
