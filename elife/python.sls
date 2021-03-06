{% set osrelease = salt['grains.get']('osrelease') %}

#
# these three states are temporary and occur when switching between 
# builder-base-formula for 14.04 and 16.04/18.04. 
# TODO: remove when all projects are using 16.04+
#

# DEPRECATED: to be removed (eventually) without replacement
python-2.7:
    pkg.installed:
        - pkgs: 
            - python2.7
            - python-pip

# 3.5 in 16.04
# 3.6 in 18.04
python-3:
    pkg.installed:
        - pkgs:
            - python3
            - python3-pip
            - python3-venv

python-dev:
    pkg.installed:
        - pkgs:
            - python2.7-dev
            - python3-dev
            - libffi-dev 
            - libssl-dev
        - require:
            - python-2.7
            - python-3

global-python-requisites:
    cmd.run:
        # lsh@2020-03: temporary upper bound until this issue is fixed:
        # - https://github.com/saltstack/salt/issues/56238
        - name: python3 -m pip install "virtualenv<20.0.0" --upgrade
        - require:
            - python-2.7

