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
# service
#

# php in ubuntu 14.04 comes with a transistive dependency on apache2 by default. 
# when we install php, we don't know if we are going to be using nginx or apache
# so it installs apache by default if it can't find any other webserver
# this is an arse, a bug, and the below is a hack.
kill-me-an-injun:
    service.dead:
        - name: apache2
        - enable: False
        - onlyif:
            - which apache2

nginx-server-service:
    service.running:
        - name: nginx
        - require:
            - pkg: nginx-server
            - service: kill-me-an-injun
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
