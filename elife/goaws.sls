goaws-configuration:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/goaws/conf/goaws.yaml
        - source: salt://elife/config/home-deploy-user-goaws-conf-goaws.yaml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - require:
            - deploy-user

goaws-docker-compose-environment:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/goaws/.env
        - source: salt://elife/config/home-deploy-user-goaws-.env
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - goaws-configuration

goaws:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/goaws/docker-compose.yml
        - source: salt://elife/config/home-deploy-user-goaws-docker-compose.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - deploy-user
            - docker-compose
            - goaws-configuration

    cmd.run:
        - name: |
            rm -f ../goaws-docker-compose.yml
            (docker stop goaws && docker rm goaws) || true
            /usr/local/bin/docker-compose -f docker-compose.yml up --force-recreate -d
        - cwd: /home/{{ pillar.elife.deploy_user.username }}/goaws
        - require:
            - goaws-configuration
            - goaws-docker-compose-environment
            - file: goaws
