# deprecated, use webserver-error-pages.sls instead

nginx-error-pages:
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
            - file: nginx-error-pages
        - watch_in:
            - service: nginx-server-service
