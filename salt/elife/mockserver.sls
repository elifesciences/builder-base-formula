docker-compose-mockserver:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/mockserver/docker-compose.yml
        - source: salt://elife/config/home-deploy-user-mockserver-docker-compose.yml
        - user: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - makedirs: True
        - require: 
            - deploy-user
            - docker-ready

{% for name, file in pillar.elife.mockserver.expectations.items() %}
docker-compose-mockserver-expectations-{{ name }}:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/mockserver/expectations/{{ name }}.sh
        - source: {{ file }}
        - user: {{ pillar.elife.deploy_user.username }}
        - mode: 755
        - makedirs: True
        - require: 
            - docker-compose-mockserver
{% endfor %}

docker-compose-mockserver-up:
    cmd.run:
        - name: /usr/local/bin/docker-compose -f docker-compose.yml up --force-recreate -d
        - cwd: /home/{{ pillar.elife.deploy_user.username }}/mockserver
        - require: 
            - docker-compose-mockserver
