# http://www.postgresql.org/download/linux/ubuntu/
postgresql-deb:
    cmd.run:
        - name: wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

    pkgrepo.managed:
        # http://www.postgresql.org/download/linux/ubuntu/
        - humanname: Official Postgresql Ubuntu LTS
        - name: deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
        - require:
            - cmd: postgresql-deb

postgresql:
    pkg.installed:
        - pkgs:
            - postgresql-9.4
            - libpq-dev # headers for building the libraries to them
        - require:
            - pkgrepo: postgresql-deb

    service.running:
        - enable: True
        - require:
            - pkg: postgresql

postgresql-config:
    file.managed:
        - name: /etc/postgresql/9.4/main/pg_hba.conf
        - source: salt://elife/config/etc-postgresql-9.4-main-pg_hba.conf
        - require:
            - pkg: postgresql
        - watch_in:
            - service: postgresql

{% if salt['elife.cfg']('cfn.outputs.RDSHost') %}
# create the not-quite-super RDS user
rds-postgresql-user:
    postgres_user.present:
        - name: {{ pillar.elife.db_root.username }}
        - password: {{ pillar.elife.db_root.password }}
        # https://github.com/saltstack/salt/issues/11821
        - refresh_password: True
        - db_password: {{ salt['elife.cfg']('project.rds_password') }}
        - db_host: {{ salt['elife.cfg']('cfn.outputs.RDSHost') }}
        - db_port: {{ salt['elife.cfg']('cfn.outputs.RDSPort') }}
        - login: True
        - require:
            - pkg: postgresql
{% endif %}

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

