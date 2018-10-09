{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease != "14.04" %}

#
# these three states are temporary and occur when switching between 
# builder-base-formula for 14.04 and 16.04/18.04. 
# TODO: remove when all projects are using 16.04+
#

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
    pip.installed:
        #- pip_bin: /usr/bin/python2.7
        - pkgs:
            # DEPRECATED. installed for any remaining python 2 apps creating virtualenvs
            - virtualenv>=13
        - require:
            - python-2.7

{% else %}

# 14.04
# DEPRECATED. remove after switch to 16.04+

# WARN: assumes python 2.7.12+, pip and setuptools are already installed and 
# updated via bootstrap script

python-dev:
    pkg.installed:
        - pkgs:
            - python-dev
            - libffi-dev 
            - libssl-dev

python-2.7:
    cmd.run:
        - name: echo Managed by builder. Remove when no other formulas depend on it

python-pip:
    cmd.run:
        - name: echo Managed by builder. Remove when no other formulas depend on it

global-python-requisites:
    cmd.run:
        # rmrf_enter is DEPRECATED
        # elife's delete script for stuff that accumulates
        - name: /usr/bin/python2.7 -m pip install "virtualenv>=13" "git+https://github.com/elifesciences/rmrf_enter.git@master#egg=rmrf_enter" --no-cache-dir
        - require:
            - pkg: base

{% endif %}
