{% for username in [pillar.elife.deploy_user.username, 'ubuntu'] %}
docker-login-{{ username }}:
    cmd.run:
        {% if pillar.elife.env != 'dev' %}
        - name: docker login --username {{ pillar.elife.docker.username }} --password-stdin
        {% else %}
        - name: echo Simulated 'docker login'
        {% endif %}
        - stdin: {{ pillar.elife.docker.password }}
        - user: {{ username }}
        - require:
            - docker-ready
{% endfor %}
