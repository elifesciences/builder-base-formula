include:
 - elife.base

# postgresql-14.sls is intended to be a drop-in replacement for postgresql-13.sls
# all are mutually exclusive and share many of the same state names

# These versions of ubuntu have been moved to the postgres apt archive,
# and the repo URL needs to be different
{% set archived_osreleases = ["18.04", "20.04"] %}

{% set oscodename = salt['grains.get']('oscodename') %}
{% set leader = salt['elife.cfg']('project.node', 1) == 1 %}

# http://www.postgresql.org/download/linux/ubuntu/


postgresql-deb-repo-remove:
    file.line:
        - name: /etc/apt/sources.list
        - mode: delete
        {% if salt['grains.get']('osrelease') in archived_osreleases %}
        - content: deb http://apt.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        {% else %}
        - content: deb http://apt-archive.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        {% endif %}
        - require_in:
            - base-latest-pkgs

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
            - postgresql-deb-repo-remove

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
            - postgresql-14
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

psql-13 to psql-14 migration:
    file.managed:
        - name: /root/upgrade-postgresql-13-to-14.sh
        - source: salt://elife/scripts/root-upgrade-postgresql-13-to-14.sh

    cmd.script:
        - name: salt://elife/scripts/root-upgrade-postgresql-13-to-14.sh
        - require:
            - pkg: postgresql
            - file: psql-13 to psql-14 migration

postgresql-config:
    file.managed:
        - name: /etc/postgresql/14/main/pg_hba.conf
        - source: salt://elife/config/etc-postgresql-14-main-pg_hba.conf
        - makedirs: True
        - require:
            - pkg: postgresql
            - psql-13 to psql-14 migration
        - watch_in:
            - service: postgresql
        - require_in:
            - cmd: postgresql-ready

postgresql-ready:
    cmd.run:
        - name: echo "PostgreSQL is set up and ready"
        - require:
            - postgresql
