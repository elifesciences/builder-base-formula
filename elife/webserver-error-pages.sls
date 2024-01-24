webserver-error-pages:
    file.directory:
        - name: /srv/error-pages
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - deploy-user

    git.latest:
        - name: git@github.com:elifesciences/error-pages.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: master
        - branch: master
        - target: /srv/error-pages/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - require:
            - file: webserver-error-pages
        {% if pillar.elife.webserver.app == "caddy" %}
        - watch_in:
            - service: caddy-server-service
        {% endif %}
        {% if pillar.elife.webserver.app == "nginx" %}
        - watch_in:
            - service: nginx-server-service
        {% endif %}
