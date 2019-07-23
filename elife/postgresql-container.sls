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
            # don't do this, messes with systemctl, can mess with apt, doesn't stop postgresql from running
            #rm -f /lib/systemd/system/postgresql*

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
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - docker-compose-postgres-up
