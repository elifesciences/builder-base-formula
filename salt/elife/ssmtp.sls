ssmtp:
    pkg.installed:
        - pkgs:
            - bsd-mailx
            - ssmtp

ssmtp-conf:        
    file.managed:
        - name: /etc/ssmtp/ssmtp.conf
        - source: salt://elife/config/etc-ssmtp-ssmtp.conf
        - mode: 640
        - group: mail
        - template: jinja
        - require:
            - pkg: ssmtp
            
ssmtp-revaliases:
    file.managed:
        - name: /etc/ssmtp/revaliases
        - source: salt://elife/config/etc-ssmtp-revaliases
        - template: jinja
        - require:
            - pkg: ssmtp
