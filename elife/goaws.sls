goaws:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/goaws-docker-compose.yml
        - source: salt://elife/config/home-deploy-user-goaws-docker-compose.yml
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - docker-compose

    cmd.run:
        - name: |
            /usr/local/bin/docker-compose -f goaws-docker-compose.yml up --force-recreate -d
        - cwd: /home/{{ pillar.elife.deploy_user.username }}
        - require:
            - file: goaws
