docker-network-sidecars:
    cmd.run:
        - name: docker network create sidecars
        - unless:
            - docker network inspect sidecars
        - require:
            - docker-ready

{% for key, configuration in pillar.elife.sidecars.containers.items() %}
# TODO: use configuration['enabled'] to turn on/off

docker-compose-{{ configuration['name'] }}:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/{{ configuration['name'] }}/docker-compose.yml
        - source: salt://elife/config/home-deploy-user-configuration-name-docker-compose.yml
        - template: jinja
        - context:
            image: {{ configuration['image'] }}
            name: {{ configuration['name'] }}
            port: {{ configuration['port'] }}
        - makedirs: True
        - require: 
            - deploy-user
            - docker-ready

docker-compose-{{ configuration['name'] }}-.env:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/{{ configuration['name'] }}/.env
        - source: salt://elife/config/home-deploy-user-configuration-name-.env
        - template: jinja
        - context:
            tag: {{ salt['elife.image_label'](pillar.elife.sidecars.main, 'org.elifesciences.dependencies.'+configuration['name']), salt['elife.image_tag']() }}
        - makedirs: True
        - require: 
            - docker-compose-{{ configuration['name'] }}

docker-compose-{{ configuration['name'] }}-up:
    cmd.run:
        - name: /usr/local/bin/docker-compose -f docker-compose.yml up --force-recreate -d
        - cwd: /home/{{ pillar.elife.deploy_user.username }}/{{ configuration['name'] }}
        - require: 
            - docker-compose-{{ configuration['name'] }}
            - docker-compose-{{ configuration['name'] }}-.env
{% endfor %}
