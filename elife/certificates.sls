#
# certificates
# your ssl-enabled application is responsible for depositing the certificate
# in this directory. 
#

web-certificates-dir:
    file.directory:
        - name: /etc/certificates
        - user: root
        - group: {{ pillar.elife.webserver.username }}
        - mode: 640
        - recurse:
            - user
            - group
            - mode

{% if salt['elife.cfg']('cfn.outputs.DomainName') %}
web-certificate-file:
    file.managed:
        - name: /etc/certificates/certificate.crt
        - source: salt://elife/config/etc-certificates-certificate.crt
        - require:
            - file: web-certificates-dir

web-private-key:
    file.managed:
        - name: /etc/certificates/privkey.pem
        - source: salt://elife/config/etc-certificates-privkey.pem
        - require:
            - file: web-certificates-dir

web-fullchain-key:
    file.managed:
        - name: /etc/certificates/fullchain.pem
        - source: salt://elife/config/etc-certificates-fullchain.pem
        - require:
            - file: web-certificates-dir

better-dhe:
    cmd.run:
        - cwd: /etc/ssl/certs
        - name: openssl dhparam -out dhparam.pem 2048
        - unless:
            - test -e /etc/ssl/certs/dhparam.pem

# useful to depend upon
web-ssl-enabled:
    cmd.run:
        - name: echo "ssl enabled"
        - require_in:
            - file: web-fullchain-key
            - file: web-private-key
            - file: web-certificate-file
            - cmd: better-dhe

{% endif %}
