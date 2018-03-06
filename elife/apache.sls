{% set wwwuser = pillar.elife.webserver %}
{% set user = pillar.elife.deploy_user %}

include:
    - .certificates

apache2:
    pkg:
        - installed
    
    file.managed:
        - name: /etc/apache2/apache2.conf
        - source: salt://elife/config/etc-apache2.4-apache2.conf
        - require:
            - pkg: apache2

enable-common-modules:
    cmd.run:
        - name: a2enmod rewrite expires ssl headers
        - require:
            - pkg: apache2

add-better-ssl-config:
    file.managed:
        - name: /etc/apache2/conf-enabled/ssl.conf
        - source: salt://elife/config/etc-apache2-conf-enabled-ssl.conf
        - template: jinja
        - require:
            - pkg: apache2
        - watch_in:
            - service: apache2-server

disable-default-apache-site:
    cmd.run:
        - name: a2dissite 000-default
        - require:
            - pkg: apache2

add-deploy-user-to-apache-group:
    cmd.run:
        - name: usermod -a -G {{ wwwuser.username }} {{ user.username }}
        - require:
            - pkg: apache2
        - unless:
            - groups {{ user.username }} | grep {{ wwwuser.username }}

#
# if you want apache you also get mod php5
# see apache-php7.sls for php7 support
#

apache2-php5-mod:
    cmd.run:
        - name: a2enmod php5.6
        - require:
            - apache2

apache2-server:
    service.running:
        - name: apache2
        - require:
            - apache2-php5-mod
            - apache2

