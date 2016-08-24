{% set wwwuser = pillar.elife.webserver.username %}
{% set user = pillar.elife.deploy_user.username %}

nginx-server:
    pkg.installed:
        - pkgs:
            - nginx-full
            - apache2-utils # for generating passwords

nginx-config:
    file.managed:
        - name: /etc/nginx/nginx.conf
        - source: salt://elife/config/etc-nginx-nginx.conf
        - template: jinja
        - require:
            - pkg: nginx-server
        - listen_in:
            - service: nginx-server-service

# created by the webserver. ensure the one created is the one we're expecting
webserver-user-group:
    group.present:
        - name: {{ wwwuser }}

    user.present:
        - name: {{ wwwuser }}
        - groups:
            - www-data
        - require:
            - group: webserver-user-group

disable-default-page:
    file.absent:
        - name: /etc/nginx/sites-enabled/default
        - require:
            - pkg: nginx-server

add-deploy-user-to-nginx-group:
    cmd.run:
        - name: usermod -a -G {{ wwwuser }} {{ user }}
        - require:
            - pkg: nginx-server
        - unless:
            # TODO: test doesn't appear to work
            - groups {{ user }} | grep {{ wwwuser }}

# needs to be enabled/symlinked in
redirect-nginx-http-to-https:
    file.managed:
        - name: /etc/nginx/sites-available/unencrypted-redirect.conf
        - source: salt://elife/config/etc-nginx-sites-available-unencrypted-redirect.conf
        - template: jinja
        - require:
            - pkg: nginx-server


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

web-ssl-enabled:
    cmd.run:
        - name: echo "ssl enabled"
        - require_in:
            - file: web-fullchain-key
            - file: web-private-key
            - file: web-certificate-file
            - cmd: better-dhe

{% endif %}


#
# service
#

nginx-server-service:
    service.running:
        - name: nginx
        - require:
            - pkg: nginx-server
        - watch:
            # this might not be doing what I think it's doing:
            # https://github.com/saltstack/salt/issues/24436
            #- file: /etc/nginx/sites-enabled/*.conf
            # this too
            - file: /etc/nginx/sites-enabled/*

#
# BASIC auth 
#

{% for title, user in pillar.elife.web_users.items() %}
create-web-user-{{ title }}:
    cmd.run:
        - name: htpasswd -b -c /etc/nginx/.{{ title }}htpasswd {{ user.username }} {{ user.password }}
        - require:
            - pkg: nginx-server
        - unless:
            - test -f /etc/nginx/.{{ title }}-htpasswd
{% endfor %}
