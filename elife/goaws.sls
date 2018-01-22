goaws-configuration:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/goaws/conf/goaws.yaml
        - source: salt://elife/config/home-deploy-user-goaws-conf-goaws.yaml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - require:
            - deploy-user

goaws:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/goaws-docker-compose.yml
        - source: salt://elife/config/home-deploy-user-goaws-docker-compose.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - deploy-user
            - docker-compose

    cmd.run:
        - name: |
            /usr/local/bin/docker-compose -f goaws-docker-compose.yml up --force-recreate -d
        - cwd: /home/{{ pillar.elife.deploy_user.username }}
        - require:
            - goaws-configuration
            - file: goaws
