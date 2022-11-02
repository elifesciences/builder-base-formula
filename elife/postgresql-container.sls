{% set psql11 = (pillar.elife.docker_postgresql.image_tag|string).startswith("11") %}

# copied from postgresql-client.sls

{% set oscodename = salt['grains.get']('oscodename') %}

# http://www.postgresql.org/download/linux/ubuntu/
postgresql-deb:
    pkgrepo.managed:
        # http://www.postgresql.org/download/linux/ubuntu/
        - humanname: Official Postgresql Ubuntu LTS
        - name: deb http://apt.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc

postgresql-client:
    pkg.installed:
        - pkgs:
            - postgresql-client-11
        - refresh: True
        - require:
            - pkgrepo: postgresql-deb

# /copied from

docker-compose-postgres:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/postgres/docker-compose.yml
        - source: salt://elife/config/home-deploy-user-postgres-docker-compose.yml
        - template: jinja
        - makedirs: True
        - require: 
            - deploy-user
            - docker-ready

docker-compose-postgres-.env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/postgres/.env
        - source: salt://elife/config/home-deploy-user-postgres-.env
        - template: jinja
        - makedirs: True
        - require: 
            - docker-compose-postgres

docker-compose-postgres-containers.env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/postgres/containers.env
        - source: salt://elife/config/home-deploy-user-postgres-containers.env
        - template: jinja
        - makedirs: True
        - require: 
            - docker-compose-postgres

# 2019-07-22: postgresql-client.sls not present on projects where postgresql-container.sls is present (digests, profiles)
# this means we can't extend the original 'postgres' state and stop its installation that way.
# I'm assuming it was at some point but isn't any more, leaving bits behind. 
# If so, this is a transitionary state and should be marked as deprecated and removed once all instances updated
stop-disable-host-postgresql:
    cmd.run:
        - name: |
            set -e
            /etc/init.d/postgresql stop || systemctl stop postgresql || true  # if anything's running locally
            systemctl disable postgresql || true # service units already deleted or postgresql never installed

docker-compose-postgres-up:
    cmd.run:
        - name: |
            /usr/local/bin/docker-compose --file docker-compose.yml up --force-recreate --detach
        - cwd: /home/{{ pillar.elife.deploy_user.username }}/postgres
        - require:
            - stop-disable-host-postgresql
            - docker-compose-postgres
            - docker-compose-postgres-.env
            - docker-network-databases

postgresql-ready:
    cmd.run:
        - name: wait_for_port 5432
        - runas: {{ pillar.elife.deploy_user.username }}
        - require:
            - docker-compose-postgres-up
