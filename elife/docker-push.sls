docker-login:
    cmd.run:
        {% if pillar.elife.env != 'dev' %}
        - name: docker login --username {{ pillar.elife.docker.username }} --password-stdin
        {% else %}
        - name: echo Simulated 'docker login'
        {% endif %}
        - stdin: {{ pillar.elife.docker.password }}
        - require:
            - docker-ready
