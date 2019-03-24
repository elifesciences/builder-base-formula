#
# uWSGI is used to bridge nginx and python
#
# If you provide a pillar.elife.uwsgi.services dictionary,
# - the key is the name of the service
# - 'folder' should indicate the /srv/... folder containing the project, which
# -- must contain a venv/bin/uwsgi binary
# -- must contain a uwsgi.ini file
# -- may contain a venv/bin/newrelic-admin binary
# -- may contain a newrelic.ini file
#

{% if salt['grains.get']('osrelease') == "14.04" %}

# warning: apps should be installing and using their own version of uwsgi
# this is here for legacy reasons only

uwsgi-pkg:
    cmd.run:
        - name: pip install "uwsgi>=2.0.8"
        - require:
            - python-dev
        - reload_modules: True

{% else %} # 16.04, 18.04, ...

uwsgi-pkg:
    pkg.installed:
        - pkgs:
            - gcc # needed for building uwsgi

{% endif %}

include:
    - .uwsgi-params

uwsgi-logrotate-def:
    file.managed:
        - name: /etc/logrotate.d/uwsgi
        - source: salt://elife/config/etc-logrotate.d-uwsgi

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

{% if salt['grains.get']('osrelease') == "14.04" %}
uwsgi-sock-dir:
    file.directory:
        - name: /run/uwsgi/
        - user: {{ pillar.elife.webserver.username }}
        - require:
            - uwsgi-pkg
{% endif %}

# systemd (Ubuntu 16.04+ only)
# application formula must still:
# * extend the pillar data with elife.uwsgi.services: appname: config
# * install and configure the application
# * declare the service and socket and ensure they are running
{% if salt['grains.get']('osrelease') != "14.04" %}

{% for name, configuration in pillar.elife.uwsgi.services.items() %}
# owned by root:www-data and writeable by both
uwsgi-{{ name }}.log:
    file.managed:
        - name: /var/log/uwsgi-{{ name }}.log
        - user: root
        - group: {{ pillar.elife.webserver.username }}
        - mode: 664

uwsgi-service-{{ name }}:
    file.managed:
        - name: /lib/systemd/system/uwsgi-{{ name }}.service
        - source: salt://elife/config/lib-systemd-system-uwsgi-service.service
        - template: jinja
        - context:
            name: {{ name }}
            folder: {{ configuration.folder }}
            # newrelic is considered available if it hasn't been explicitly disabled
            disable_newrelic: {{ configuration.get('disable_newrelic', False) }}
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

{% endif %}
