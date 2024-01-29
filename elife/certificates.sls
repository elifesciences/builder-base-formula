#
# certificates
# ssl-enabled applications should look for and add certificates to /etc/certificates
# depends on 'www-user.sls'
#

etc-certificates-group:
    group.present:
        - name: {{ pillar.elife.certificates.username }}

{% if salt['elife.cfg']('cfn.outputs.DomainName') %}

# why this usage of 'app'?
# not all applications use this default certificate and need to provide their own (redirects).
# using "salt://$appname/config/path-to-some-config" is one way to do that.
{% set app = pillar.elife.certificates.app or 'elife' %}

etc-certificates-dir:
    file.directory:
        - name: /etc/certificates
        - user: root
        - group: {{ pillar.elife.certificates.username }}
        - mode: 750
        - recurse:
            - user
            - group
            - mode
        - require:
            - etc-certificates-group

etc-certificates-cert:
    file.managed:
        - name: /etc/certificates/certificate.crt
        - group: {{ pillar.elife.certificates.username }}
        - source: salt://{{ app }}/config/etc-certificates-certificate.crt
        - require:
            - etc-certificates-dir

etc-certificates-private-key:
    file.managed:
        - name: /etc/certificates/privkey.pem
        - source: salt://{{ app }}/config/etc-certificates-privkey.pem
        - group: {{ pillar.elife.certificates.username }}
        - require:
            - etc-certificates-dir

etc-certificates-fullchain-key:
    file.managed:
        - name: /etc/certificates/fullchain.pem
        - source: salt://{{ app }}/config/etc-certificates-fullchain.pem
        - group: {{ pillar.elife.certificates.username }}
        - require:
            - etc-certificates-dir

etc-certificates-complete-cert:
    cmd.run:
        - name: cat certificate.crt fullchain.pem > certificate.chained.crt && chgrp {{ pillar.elife.certificates.username }} certificate.chained.crt
        - cwd: /etc/certificates/
        # only trigger state if either of these two files have changed
        - onchanges:
            - etc-certificates-fullchain-key
            - etc-certificates-cert
        - require:
            - etc-certificates-fullchain-key
            - etc-certificates-cert

better-dhe:
    cmd.run:
        - cwd: /etc/ssl/certs
        - name: openssl dhparam -dsaparam -out dhparam.pem 2048
        - unless:
            - test -e /etc/ssl/certs/dhparam.pem

# useful to depend upon
web-ssl-enabled:
    cmd.run:
        - name: echo "ssl enabled"
        - require_in:
            - file: etc-certificates-fullchain-key
            - file: etc-certificates-private-key
            - file: etc-certificates-cert
            - cmd: etc-certificates-complete-cert
            - cmd: better-dhe

{% else %}

# prevents further conditionals downstream
web-ssl-enabled:
    cmd.run:
        - name: echo "ssl NOT enabled"

{% endif %}
