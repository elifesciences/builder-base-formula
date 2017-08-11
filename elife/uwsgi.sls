#
# uWSGI is used to bridge nginx and python
#

# apps should be installing and using their own version of uwsgi
#uwsgi-pkg:
#    pip.installed:
#        - name: uwsgi >= 2.0.8
#        - require:
#            - pkg: python-pip
#            - pkg: python-dev
#        - reload_modules: True

uwsgi-pkg:
    pkg.installed:
        - pkgs:
            - gcc # needed for building uwsgi

uwsgi-params:
    file.managed:
        - name: /etc/uwsgi/params
        - makedirs: True
        - source: salt://elife/config/etc-uwsgi-params
        #- require:
        #    - pip: uwsgi-pkg

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

#uwsgi-sock-dir:
#    file.directory:
#        - name: /run/uwsgi/
#        - user: {{ pillar.elife.webserver.username }}
#        - require:
#            - pip: uwsgi-pkg
