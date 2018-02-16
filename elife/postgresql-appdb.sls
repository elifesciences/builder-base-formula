# creates a generic database, user and set of privileges
# this state obviates a chunk of boilerplate code in app formulas and makes 
# testing more convenient.

{% set user = salt['elife.cfg']('project.rds_username', pillar.elife.db.root.username) %}
{% set pass = salt['elife.cfg']('project.rds_password', pillar.elife.db.root.password) %}
{% set host = salt['elife.cfg']('cfn.outputs.RDSHost', pillar.elife.postgresql.host) %}
{% set port = salt['elife.cfg']('cfn.outputs.RDSPort', pillar.elife.postgresql.port) %}

# new

{% set db_name = salt['elife.cfg']('project.rds_dbname', pillar.elife.db.app.name) %}
{% set app_user_name = pillar.elife.db.app.username %}
{% set app_user_pass = pillar.elife.db.app.password %}

{% set db_exists = salt.get('postgres.db_exists') and salt['postgres.db_exists'](db_name, user=user, host=host, password=pass) %}
{% set app_user_exists = salt.get('postgres.user_exists') and salt['postgres.user_exists'](app_user_name, host=host, password=pass) %}

db-perms-to-rds_superuser:
    cmd.script:
    {% if db_exists and app_user_exists %}
        - name: salt://elife/scripts/postgresql-appdb-perms-migration.sh
    {% else %}
        - name: salt://elife/scripts/postgresql-appdb-perms.sh
    {% endif %}
        - creates: /root/db-permissions-set.flag
        - template: jinja
        - defaults:
            user: {{ user }}
            pass: {{ pass }}
            host: {{ host }}
            port: {{ port }}
            db_name: {{ db_name }}
            app_user_name: {{ app_user_name }}
            app_user_pass: {{ app_user_pass }}

psql-app-db:
    postgres_database.present:
        - name: {{ db_name }}
        - owner: {{ user }}
        - owner_recurse: True # all tables get the same owner

        - db_user: {{ user }}
        - db_password: {{ pass }}
        - db_host: {{ host }}
        - db_port: {{ port }}
        - require:
            - db-perms-to-rds_superuser

    postgres_user.present:
        - name: {{ app_user_name }}
        - password: {{ app_user_pass }}
        - encrypted: True
        - refresh_password: True
        - createdb: {% if pillar.elife.env in ['prod', 'end2end'] %}False{% else %}True{% endif %}

        - db_user: {{ user }}
        - db_password: {{ pass }}
        - db_host: {{ host }}
        - db_port: {{ port }}
        - require:
            - postgres_database: psql-app-db

