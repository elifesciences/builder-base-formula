gearman-daemon:
    pkg.installed:
        - pkgs:
            - gearman-job-server
            - gearman-tools

# the default Upstart script is broken and ignores /etc/default/gearman
# https://bugs.launchpad.net/ubuntu/+source/gearmand/+bug/1260830/
# replacing would require an additional restart if we modify the configuration
# here, but projects perform the restart by themselves after *they* modify it
gearman-upstart-script:
    file.managed:
        - name: /etc/init/gearman-job-server.conf
        - source: salt://elife/config/etc-init-gearman-job-server.conf
        - require:
            - gearman-daemon

# -----

gearman-systemd-script:
    file.managed:
        - name: /lib/systemd/system/gearman-job-server.service
        - source: salt://elife/config/lib-systemd-system-gearman-job-server.service
        - require:
            - gearman-daemon

gearman-configuration-old:
    file.absent:
        - name: /etc/default/gearman-job-server

gearman-configuration:
    file.managed:
        - name: /etc/gearman.conf
        - source: salt://elife/config/etc-gearman.conf
        - template: jinja
        - require:
            - gearman-daemon

{% if pillar.elife.gearman.persistent %}
{% set gdb = pillar.elife.gearman.db %}

gearman-db-user:
    postgres_user.present:
        - name: {{ gdb.username }}
        - encrypted: True
        - password: {{ gdb.password }}
        - refresh_password: True
        - db_user: {{ pillar.elife.db_root.username }}
        - db_password: {{ pillar.elife.db_root.password }}
        - createdb: True
        - require:
            - postgresql-ready

gearman-db:
    postgres_database.present:
        - name: {{ gdb.name }}
        - owner: {{ gdb.username }}
        - db_user: {{ gdb.username }}
        - db_password: {{ gdb.password }}
        - require:
            - postgres_user: gearman-db-user

    {% if pillar.elife.env in ['dev', 'ci'] %}
clear-gearman:
    cmd.run:
        - env:
            - PGPASSWORD: {{ gdb.password }}
        - name: |
            psql --no-password {{ gdb.name}} {{ gdb.username }} -c 'DELETE FROM queue' || { echo "'queue' table not found"; }
        #- watch_in:
        #    - service: gearman-service
        - require:
            - gearman-daemon
            #- gearman-service # creates a recursive requisite
    {% endif %}

{% endif %}
