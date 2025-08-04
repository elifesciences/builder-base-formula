# postgresql-13.sls is intended to be a drop-in replacement for postgresql-12.sls
# all are mutually exclusive and share many of the same state names

# These versions of ubuntu have been moved to the postgres apt archive,
# and the repo URL needs to be different
{% set archived_osreleases = ["18.04", "20.04"] %}

{% set oscodename = salt['grains.get']('oscodename') %}
{% set leader = salt['elife.cfg']('project.node', 1) == 1 %}

# http://www.postgresql.org/download/linux/ubuntu/


postgresql-deb-repo-remove:
    pkgrepo.absent:
        # http://www.postgresql.org/download/linux/ubuntu/
        - humanname: Official Postgresql Ubuntu LTS
        - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
        {% if salt['grains.get']('osrelease') in archived_osreleases %}
        - name: deb http://apt.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        {% else %}
        - name: deb http://apt-archive.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        {% endif %}


postgresql-deb:
    pkgrepo.managed:
        # http://www.postgresql.org/download/linux/ubuntu/
        - humanname: Official Postgresql Ubuntu LTS
        - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
        {% if salt['grains.get']('osrelease') in archived_osreleases %}
        - name: deb http://apt-archive.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        {% else %}
        - name: deb http://apt.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        {% endif %}
        - require:
            - pkgrepo: postgresql-deb-repo-remove

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
            - postgresql-13
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

postgresql-config:
    file.managed:
        - name: /etc/postgresql/13/main/pg_hba.conf
        - source: salt://elife/config/etc-postgresql-13-main-pg_hba.conf
        - makedirs: True
        - require:
            - pkg: postgresql
        - watch_in:
            - service: postgresql
        - require_in:
            - cmd: postgresql-ready

# runs pg_upgrade on 12 data and then purges postgresql-13
psql-12 to psql-13 migration:
    file.managed:
        - name: /root/upgrade-postgresql-12-to-13.sh
        - source: salt://elife/scripts/root-upgrade-postgresql-12-to-13.sh

    cmd.script:
        - name: salt://elife/scripts/root-upgrade-postgresql-12-to-13.sh
        - require:
            - pkg: postgresql
            - pgpass-file
            - postgresql-config
            - file: psql-12 to psql-13 migration

# managing this file is necessary because of the migration
# psql 13 default config is port 5433 and not 5432 when another psql is present
more-postgresql-config:
    file.managed:
        - name: /etc/postgresql/13/main/conf.d/port.conf
        - source: salt://elife/config/etc-postgresql-13-main-conf.d-port.conf
        - makedirs: True
        - require:
            - pkg: postgresql
            # run the migration first, which will purge the old 12 postgresql, then
            # enforce new config with port 5432 here
            - cmd: psql-12 to psql-13 migration
        - watch_in:
            - service: postgresql
        - require_in:
            - cmd: postgresql-ready

{% if salt['elife.cfg']('cfn.outputs.RDSHost') %}
# create the not-quite-super RDS user

# lsh@2022-02-11: occasional problems when running this state in parallel:
# - https://github.com/elifesciences/issues/issues/7224
{% if leader %}

rds-postgresql-user:
    postgres_user.present:
        - name: {{ pillar.elife.db_root.username }}
        - password: {{ salt['elife.cfg']('project.rds_password') }}
        - encrypted: scram-sha-256
        - refresh_password: True
        - db_password: {{ salt['elife.cfg']('project.rds_password') }}
        - db_host: {{ salt['elife.cfg']('cfn.outputs.RDSHost') }}
        - db_port: {{ salt['elife.cfg']('cfn.outputs.RDSPort') }}
        - login: True
        - require:
            - pkg: postgresql
        - require_in:
            - cmd: postgresql-ready

{% endif %} # ends leader

{% else %}
postgresql-user:
    postgres_user.present:
        - name: {{ pillar.elife.db_root.username }}
        - password: {{ pillar.elife.db_root.password }}
        - encrypted: scram-sha-256
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
