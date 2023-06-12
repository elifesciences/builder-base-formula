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

# lsh@2023-06-12: installing pip this way is installing an incompatible set of requests and urllib3.
# it's also general bad practice, messing with system packages
# see: https://github.com/docker/docker-py/issues/3113
#twine:
#    cmd.run:
#        # TODO: try to remove this workaround on 16.04
#        # ignore-installed because of a conflict with the chardet Python package
#        # https://stackoverflow.com/questions/50130004/installing-twine-fails-because-cannot-uninstall-pkginfo#comment96655925_50132754
#        # lsh@2020-01-13: changed from 'pip' to 'python3 -m pip'
#        #- name: python3 -m pip install twine --ignore-installed --quiet

twine:
    pkg.installed:
        - pkgs:
            - twine
