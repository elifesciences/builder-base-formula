# official command line tool to interact with Github's API

hub:
    cmd.run:
        - name: |
            wget -c https://github.com/github/hub/releases/download/v2.3.0-pre8/hub-linux-amd64-2.3.0-pre8.tgz
            tar zvxf hub-linux-amd64-2.3.0-pre8.tgz
            ln -sf /opt/hub-linux-amd64-2.3.0-pre8/bin/hub /usr/local/bin/hub
        - cwd: /opt
        - unless:
            - which hub

    file.managed:
        - name: /home/{{ pillar.elife.hub.username }}/.config/hub
        - source: salt://elife/config/home-deploy-user-.config-hub
        - template: jinja
        - makedirs: True
        - user: {{ pillar.elife.hub.username }}
        - group: {{ pillar.elife.hub.username }}
        - require:
            - deploy-user
            - cmd: hub

