# official command line tool to interact with Github's API

hub:
    cmd.run:
        - name: |
            wget -c https://github.com/github/hub/releases/download/v2.2.9/hub-linux-amd64-2.2.9.tgz
            tar zvxf hub-linux-amd64-2.2.9.tgz
            ln -sf /opt/hub-linux-amd64-2.2.9/bin/hub /usr/local/bin/hub
        - cwd: /opt
        - unless:
            - which hub

    file.managed:
        - name: /etc/hub.default
        - source: salt://elife/config/home-deploy-user-.config-hub
        - template: jinja
        - makedirs: True
        - user: {{ pillar.elife.hub.username }}
        - group: {{ pillar.elife.hub.username }}
        - require:
            - deploy-user
            - cmd: hub
            - user: {{ pillar.elife.hub.username }}

hub-link-config:
    cmd.run:
        - name: |
            cd $(eval echo "~$username")/
            mkdir -p .config
            cd .config
            ln -sf /etc/hub.default hub
        - require:
            - hub

