# official command line tool to interact with Github's API

{% set hub_version = '2.11.2' %}

hub:
    cmd.run:
        - name: |
            wget --quiet --continue https://github.com/github/hub/releases/download/v{{ hub_version }}/hub-linux-amd64-{{ hub_version }}.tgz
            tar zvxf hub-linux-amd64-{{ hub_version }}.tgz
            ln -sf /opt/hub-linux-amd64-{{ hub_version }}/bin/hub /usr/local/bin/hub
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
            cd $(eval echo "~{{ pillar.elife.hub.username }}")/
            mkdir -p .config
            chown {{ pillar.elife.hub.username}}:{{ pillar.elife.hub.username}} .config
            cd .config
            ln -sf /etc/hub.default hub
            chown -h {{ pillar.elife.hub.username}}:{{ pillar.elife.hub.username}} hub
        - require:
            - hub

