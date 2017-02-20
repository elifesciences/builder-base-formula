# most recent guide: https://stkenny.github.io/iiif/loris/2016/10/03/loris_install/
# 1. Requirements
# checkout git@github.com:loris-imageserver/loris.git
# elife:elife on /opt/loris
# git@github.com:loris-imageserver/loris.git
apache-packages:
    pkg.installed:
        - pkgs:
            - apache2
            - libapache2-mod-wsgi

apache-module-headers:
    apache_module.enabled:
        - name: headers
        - require:
            - apache-packages

apache-module-expires:
    apache_module.enabled:
        - name: expires
        - require:
            - apache-packages

apache-module-wsgi:
    apache_module.enabled:
        - name: wsgi
        - require:
            - apache-packages

apache-default-site:
    apache_site.disabled:
        - name: 000-default

apache-loris-site:
    file.managed:
        - name: /etc/apache2/sites-enabled/loris.conf
        - source: salt://elife/config/etc-apache2-sites-enabled-loris.conf
        - require:
            - apache-packages

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
            #venv/bin/pip install --no-binary :all: Pillow
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

loris-image-examples:
    cmd.run:
        - name: cp -R tests/img/* /usr/local/share/images
        - cwd: /opt/loris
        - require:
            - loris-images-folder

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

# TODO: should be on an external volume
loris-cache:
    file.directory:
        - name: /var/cache/loris2
        - user: loris
        - group: loris
        - dir_mode: 755
        - require:
            - loris-setup

loris-config:
    file.managed:
        - name: /etc/loris2/loris2.conf
        - source: salt://elife/config/etc-loris2-loris2.conf
        - template: jinja
        - require:
            - loris-setup

loris-wsgi-entry-point:
    file.managed:
        - name: /var/www/loris2/loris2.wsgi
        - source: salt://elife/config/var-www-loris2-loris2.wsgi
        - require:
            - loris-setup

apache-ready:
    service.running:
        - name: apache2
        - enable: True
        - reload: True
        - watch:
            - loris-repository
            - loris-dependencies
            - loris-setup
            - loris-config
            - loris-wsgi-entry-point
        - require:
            - apache-module-expires
            - apache-module-headers
            - apache-module-wsgi
            - apache-default-site
            - apache-loris-site
            - loris-config
            - loris-wsgi-entry-point
            - loris-cache

loris-ready:
    file.managed:
        - name: /usr/local/bin/smoke-loris
        - source: salt://elife/config/usr-local-bin-smoke-loris
        - mode: 755

    #TODO: add images
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
