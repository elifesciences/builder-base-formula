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
        # lsh@2021-07-22: pinned to version 16.7.10 as 16.7.11 released overnight has a bug that breaks
        # installation of builder on elife-alfred by attempting to use a newer version of pip that relies 
        # on typing: https://github.com/pypa/virtualenv/issues/2153
        # todo: remove pin altogether once we're wholly on python3
        - name: python3 -m pip install "virtualenv==16.7.10" --upgrade
        - require:
            - python-2.7

