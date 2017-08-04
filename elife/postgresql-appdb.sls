# creates a generic database, user and set of privileges
# this state obviates a chunk of boilerplate code in app formulas and makes 
# testing more convenient.

{% set user = salt['elife.cfg']('project.rds_username', pillar.elife.db.root.username) %}
{% set pass = salt['elife.cfg']('project.rds_username', pillar.elife.db.root.password) %}
{% set host = salt['elife.cfg']('cfn.outputs.RDSHost', pillar.elife.postgresql.host) %}
{% set port = salt['elife.cfg']('cfn.outputs.RDSPort', pillar.elife.postgresql.port) %}

# new

{% set db_name = salt['elife.cfg']('project.rds_dbname', pillar.elife.db.app.name) %}
{% set app_user_name = pillar.elife.db.app.username %}
{% set app_user_pass = pillar.elife.db.app.password %}

psql-app-db:
    postgres_database.present:
        - name: {{ db_name }}
        - owner: {{ user }}

        - db_user: {{ user }}
        - db_password: {{ pass }}
        - db_host: {{ host }}
        - db_port: {{ port }}

    postgres_user.present:
        - name: {{ app_user_name }}
        - password: {{ app_user_pass }}
        - encrypted: True
        - refresh_password: True
        - createdb: False

        - db_user: {{ user }}
        - db_password: {{ pass }}
        - db_host: {{ host }}
        - db_port: {{ port }}

db-perms-to-rds_superuser:
    cmd.script:
        - name: salt://elife/scripts/rds-perms2.sh
        - template: jinja
        - defaults:
            user: {{ user }}
            pass: {{ pass }}
            host: {{ host }}
            port: {{ port }}
            db_name: {{ db_name }}
            app_user_name: {{ app_user_name }}
            app_user_pass: {{ app_user_pass }}
        - require:
            - psql-app-db

