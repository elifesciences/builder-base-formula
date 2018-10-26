pypi-credentials-deploy-user:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.pypirc
        - source: salt://elife/config/home-user-.pypirc
        - template: jinja
        - require:
            - deploy-user

pypi-credentials-ubuntu-user:
    file.managed:
        - name: /home/ubuntu/.pypirc
        - source: salt://elife/config/home-user-.pypirc
        - template: jinja
        - require:
            - deploy-user

twine:
    cmd.run:
        - name: pip install twine
