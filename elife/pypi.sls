pypi-credentials:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.pypirc
        - source: salt://elife/config/home-deploy-user-.pypirc
        - template: jinja
        - require:
            - deploy-user
