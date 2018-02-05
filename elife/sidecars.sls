docker-network-sidecars:
    cmd.run:
        - name: docker network create sidecars
        - unless:
            - docker network inspect sidecars
        - require:
            - docker-ready

{% for key, configuration in pillar.elife.sidecars.containers.items() %}
{% if configuration['enabled'] %}

docker-compose-{{ configuration['name'] }}:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/{{ configuration['name'] }}/docker-compose.yml
        - source: salt://elife/config/home-deploy-user-configuration-name-docker-compose.yml
        - template: jinja
        - context:
            name: {{ configuration['name'] }}
            image: {{ configuration['image'] }}
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
            main: {{ pillar.elife.sidecars.main }}
            configuration: {{ configuration }}
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

{% endif %}
{% endfor %}
