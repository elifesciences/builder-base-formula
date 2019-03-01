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
        # TODO: try to remove this workaround on 16.04
        # ignore-installed because of a conflict with the chardet Python package
        # https://stackoverflow.com/questions/50130004/installing-twine-fails-because-cannot-uninstall-pkginfo#comment96655925_50132754
        - name: pip install twine --ignore-installed
