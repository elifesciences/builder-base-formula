#
# uWSGI is used to bridge nginx and python
#
# If you provide a pillar.elife.uwsgi.services dictionary,
# - the key is the name of the service
# - 'folder' should indicate the /srv/... folder containing the project, which
# -- must contain a venv/bin/uwsgi binary
# -- must contain a uwsgi.ini file
#

# warning: apps should be installing and using their own version of uwsgi
uwsgi-pkg:
    pkg.installed:
        - pkgs:
            - gcc # needed for building uwsgi

include:
    - .uwsgi-params

uwsgi-logrotate-def:
    file.managed:
        - name: /etc/logrotate.d/uwsgi
        - source: salt://elife/config/etc-logrotate.d-uwsgi
        - template: jinja

uwsgi-syslog-conf:
    file.managed:
        - name: /etc/syslog-ng/conf.d/uwsgi.conf
        - source: salt://elife/config/etc-syslog-ng-conf.d-uwsgi.conf
        - template: jinja
        - require:
            - pkg: syslog-ng
            - file: uwsgi-logrotate-def
        - watch_in:
            - service: syslog-ng

# systemd (Ubuntu 16.04+ only)
# application formula must still:
# * extend the pillar data with elife.uwsgi.services: appname: config
# * install and configure the application
# * declare the service and socket and ensure they are running

{% for name, configuration in pillar.elife.uwsgi.services.items() %}
# owned by root:www-data and writeable by both
uwsgi-{{ name }}.log:
    file.managed:
        - name: /var/log/uwsgi-{{ name }}.log
        - user: root
        - group: {{ pillar.elife.uwsgi.username }}
        - mode: 664

uwsgi-{{ name }}-logrotate-def:
    file.managed:
        - name: /etc/logrotate.d/uwsgi-{{ name }}
        - source: salt://elife/config/etc-logrotate.d-uwsgi
        - template: jinja
        - context:
            # don't use 'name' in template! it's already passed to jinja with the value of the current state name
            appname: {{ name }}

uwsgi-{{ name }}-syslog-conf:
    file.managed:
        - name: /etc/syslog-ng/conf.d/uwsgi.conf
        - source: salt://elife/config/etc-syslog-ng-conf.d-uwsgi.conf
        - template: jinja
        - context:
            appname: {{ name }}
        - require:
            - pkg: syslog-ng
            - file: uwsgi-logrotate-def
        - watch_in:
            - service: syslog-ng

uwsgi-service-{{ name }}:
    file.managed:
        - name: /lib/systemd/system/uwsgi-{{ name }}.service
        - source: salt://elife/config/lib-systemd-system-uwsgi-service.service
        - template: jinja
        - context:
            name: {{ name }}
            folder: {{ configuration.folder }}
        - require:
            - uwsgi-pkg
            - uwsgi-params
            - uwsgi-{{ name }}.log
        - require_in:
            - cmd: uwsgi-services

uwsgi-socket-{{ name }}:
    file.managed:
        - name: /lib/systemd/system/uwsgi-{{ name }}.socket
        - source: salt://elife/config/lib-systemd-system-uwsgi.socket
        - template: jinja
        - require:
            - uwsgi-pkg
            - uwsgi-params
            - uwsgi-{{ name }}.log
        - context:
            name: {{ name }}
        # necessary?
        - require_in:
            - cmd: uwsgi-services

{% endfor %}

uwsgi-services:
    cmd.run:
        - name: systemctl daemon-reload

