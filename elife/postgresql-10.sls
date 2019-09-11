# postgresql-10.sls is intended to be a drop-in replacement for postgresql.sls (psql 9.4)
# the two are mutually exclusive and share many of the same state names

# copied from postgresql-client.sls

{% set oscodename = salt['grains.get']('oscodename') %}

# http://www.postgresql.org/download/linux/ubuntu/
postgresql-deb:
    pkgrepo.managed:
        # http://www.postgresql.org/download/linux/ubuntu/
        - humanname: Official Postgresql Ubuntu LTS
        - name: deb http://apt.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc

# copied from 

pgpass-file:
    file.managed:
        - name: /root/.pgpass
        - source: salt://elife/config/root-pgpass
        - template: jinja
        - mode: 0600
        - defaults:
            user: {{ pillar.elife.db_root.username }}
            pass: {{ pillar.elife.db_root.password }}
            host: localhost
            port: 5432

{% if salt['elife.cfg']('cfn.outputs.RDSHost') %}
pgpass-rds-entry:
    file.append:
        - name: /root/.pgpass
        - source: salt://elife/config/root-pgpass
        - template: jinja
        - defaults:
            user: {{ pillar.elife.db_root.username }}
            pass: {{ salt['elife.cfg']('project.rds_password') }}
            host: {{ salt['elife.cfg']('cfn.outputs.RDSHost') }}
            port: {{ salt['elife.cfg']('cfn.outputs.RDSPort') }}
        - require:
            - pgpass-file
{% endif %}

postgresql:
    pkg.installed:
        - pkgs:
            - postgresql-10
            - libpq-dev # headers for building the libraries to them
        - require:
            - pkgrepo: postgresql-deb

{% if not salt['elife.cfg']('cfn.outputs.RDSHost') %}
    service.running:
        - enable: True
        - require:
            - pkg: postgresql
            - pgpass-file
{% else %}
    service.dead:
        - enable: False
        - require:
            - pkg: postgresql
            - pgpass-file
{% endif %}

{% if not salt['elife.cfg']('cfn.outputs.RDSHost') %}
# 12.04/14.04 legacy file, to be removed with postgresql.sls (psql 9.4)
# systemd service/target is being used in 16.04+
postgresql-init:
    file.absent:
        - name: /etc/init.d/postgresql
#        - source: salt://elife/config/etc-init.d-postgresql # remove with postgresql.sls
{% endif %}


# runs pg_upgrade on 9.4 data and then purge postgresql-9.4 
psql-9.4 to psql-10 migration:
    file.managed:
        - name: /root/upgrade-postgresql-9.4-to-10.sh
        - source: salt://elife/scripts/root-upgrade-postgresql-9.4-to-10.sh

    cmd.script:
        - name: salt://elife/scripts/root-upgrade-postgresql-9.4-to-10.sh
        - require:
            - pkg: postgresql
            - file: psql-9.4 to psql-10 migration

postgresql-config:
    file.managed:
        - name: /etc/postgresql/10/main/pg_hba.conf
        - source: salt://elife/config/etc-postgresql-10-main-pg_hba.conf
        - require:
            - pkg: postgresql
        - watch_in:
            - service: postgresql
        - require_in:
            - cmd: postgresql-ready

# managing this file is necessary because of the migration
# psql 10 default config is port 5433 and not 5432 when another psql is present
more-postgresql-config:
    file.managed:
        - name: /etc/postgresql/10/main/postgresql.conf
        - source: salt://elife/config/etc-postgresql-10-main-postgresql.conf
        - require:
            - pkg: postgresql
            # run the migration first, which will purge the old 9.x postgresql, then 
            # enforce new config with port 5432 here
            - cmd: psql-9.4 to psql-10 migration
        - watch_in:
            - service: postgresql
        - require_in:
            - cmd: postgresql-ready

{% if salt['elife.cfg']('cfn.outputs.RDSHost') %}
# create the not-quite-super RDS user
rds-postgresql-user:
    postgres_user.present:
        - name: {{ pillar.elife.db_root.username }}
        - password: {{ salt['elife.cfg']('project.rds_password') }}
        - refresh_password: True
        - db_password: {{ salt['elife.cfg']('project.rds_password') }}
        - db_host: {{ salt['elife.cfg']('cfn.outputs.RDSHost') }}
        - db_port: {{ salt['elife.cfg']('cfn.outputs.RDSPort') }}
        - login: True
        - require:
            - pkg: postgresql
        - require_in:
            - cmd: postgresql-ready
{% else %}
postgresql-user:
    postgres_user.present:
        - name: {{ pillar.elife.db_root.username }}
        - password: {{ pillar.elife.db_root.password }}
        - refresh_password: True
        - db_password: {{ pillar.elife.db_root.password }}
        
        # doesn't work on RDS instances
        - superuser: True

        - login: True
        - require:
            - pkg: postgresql
            - service: postgresql
        - require_in:
            - cmd: postgresql-ready
{% endif %}

postgresql-ready:
    cmd.run:
        - name: echo "PostgreSQL is set up and ready"
        - require:
            - postgresql
