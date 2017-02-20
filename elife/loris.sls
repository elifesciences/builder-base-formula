loris-repository:
    git.latest:
        - name: git@github.com:loris-imageserver/loris.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        # main branch as of 2017-02-20
        - rev: 400a4083c7ed20899424d4cc9922d158b3ec8f8d
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - target: /opt/loris

    file.directory:
        - name: /opt/loris
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - git: loris-repository

    virtualenv.managed:
        - name: /opt/loris/venv
        - user: {{ pillar.elife.deploy_user.username }}
        - python: /usr/bin/python2.7

loris-dependencies:
    pkg.installed:
        - pkgs:
            - libjpeg8
            - libjpeg8-dev
            - libfreetype6
            - libfreetype6-dev
            - zlib1g-dev
            - liblcms
            - liblcms-dev
            - liblcms-utils
            - liblcms2-2 
            - liblcms2-dev 
            - liblcms2-utils
            - libtiff4-dev
            - libtiff5-dev
            - libxml2-dev
            - libxslt1-dev

    cmd.run:
        - name: |
            echo "don't do anything for now"
            venv/bin/pip install Werkzeug
            venv/bin/pip install configobj
            venv/bin/pip install Pillow
            venv/bin/pip install uwsgi==2.0.14
        - cwd: /opt/loris
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - loris-repository
            - pkg: loris-dependencies


loris-user:
    user.present: 
        - name: loris
        - shell: /sbin/false
        - home: /home/loris

loris-images-folder:
    file.directory:
        - name: /usr/local/share/images
        - user: loris

# only runs on second time?
# has to be run multiple times, unclear what it's doing
# add requires, experiment
loris-setup:
    cmd.run:
        - name: |
            venv/bin/python setup.py install
        - user: root
        - cwd: /opt/loris
        - require:
            - loris-dependencies
            - loris-user
            - loris-images-folder

loris-cache-general:
    file.directory:
        - name: {{ pillar.elife.loris.storage }}/cache-general
        - user: loris
        - group: loris
        - dir_mode: 755
        - makedirs: True
        - require:
            - loris-setup

loris-cache-resolver:
    file.directory:
        - name: {{ pillar.elife.loris.storage }}/cache-resolver
        - user: loris
        - group: loris
        - dir_mode: 755
        - makedirs: True
        - require:
            - loris-setup

loris-config:
    file.managed:
        - name: /etc/loris2/loris2.conf
        - source: salt://elife/config/etc-loris2-loris2.conf
        - template: jinja
        - require:
            - loris-setup
            - loris-cache-general
            - loris-cache-resolver

loris-wsgi-entry-point:
    file.managed:
        - name: /var/www/loris2/loris2.wsgi
        - source: salt://elife/config/var-www-loris2-loris2.wsgi
        - require:
            - loris-setup

loris-uwsgi-configuration:
    file.managed:
        - name: /etc/loris2/uwsgi.ini
        - source: salt://elife/config/etc-loris2-uwsgi.ini
        - require:
            - loris-setup

loris-uwsgi-log:
    file.managed:
        - name: /var/log/uwsgi-loris.log
        # don't want to lose any write to this
        - mode: 666

loris-uwsgi-ready:
    file.managed:
        - name: /etc/init/uwsgi-loris.conf
        - source: salt://elife/config/etc-init-uwsgi-loris.conf
        - require:
            - loris-uwsgi-configuration
            - loris-uwsgi-log

    service.running:
        - name: uwsgi-loris
        - enable: True
        - restart: True
        - watch:
            - loris-repository
            - loris-dependencies
            - loris-setup
            - loris-config
            - loris-wsgi-entry-point

loris-nginx-ready:
    file.managed:
        - name: /etc/nginx/sites-enabled/loris.conf
        - source: salt://elife/config/etc-nginx-sites-enabled-loris.conf
        - template: jinja
        - require:
            - loris-uwsgi-ready

    service.running:
        - name: nginx
        - enable: True
        - reload: True
        - watch:
            - file: loris-nginx-ready

loris-ready:
    file.managed:
        - name: /usr/local/bin/smoke-loris
        - source: salt://elife/config/usr-local-bin-smoke-loris
        - template: jinja
        - mode: 755
        - require:
            - loris-nginx-ready

    cmd.run:
        - name: |
            smoke-loris
        - require:
            - file: loris-ready

loris-logrotate:
    file.managed:
        - name: /etc/logrotate.d/loris
        - source: salt://elife/config/etc-logrotate.d-loris
        - template: jinja

# TODO: optimize with unless
