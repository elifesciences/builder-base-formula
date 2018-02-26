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

docker-compose-postgres-up:
    cmd.run:
        - name: |
            /etc/init.d/postgresql stop || true  # if anything's running locally
            /usr/local/bin/docker-compose -f docker-compose.yml up --force-recreate -d
        - cwd: /home/{{ pillar.elife.deploy_user.username }}/postgres
        - require: 
            - docker-compose-postgres
            - docker-compose-postgres-.env

postgresql-ready:
    cmd.run:
        - name: wait_for_port 5432
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - docker-compose-postgres-up
