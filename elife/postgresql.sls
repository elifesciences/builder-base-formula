include:
    - .postgresql-client 

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
{% endif %}

postgresql:
    pkg.installed:
        - pkgs:
            - postgresql-9.4
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

# TODO: remove this, not used in 16.04+, uncertain about 14.04
{% if not salt['elife.cfg']('cfn.outputs.RDSHost') %}
postgresql-init:
    file.managed:
        - name: /etc/init.d/postgresql
        - source: salt://elife/config/etc-init.d-postgresql
        - require:
            - pkg: postgresql
        - require_in:
            - cmd: postgresql-ready
{% endif %}

postgresql-config:
    file.managed:
        - name: /etc/postgresql/9.4/main/pg_hba.conf
        - source: salt://elife/config/etc-postgresql-9.4-main-pg_hba.conf
        - require:
            - pkg: postgresql
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
