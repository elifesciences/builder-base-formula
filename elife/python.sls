{% if salt['grains.get']('osrelease') == "16.04" %}

#
# these states are temporary and occur when switching between 
# builder-base-formula for 14.04 and 16.04. 
# TODO: remove when all projects are using 16.04
#

dead-snakes-are-dead:
    pkgrepo.absent:
        - ppa: fkrull/deadsnakes-python2.7

jonothonf-is-missing:
    pkgrepo.absent:
        - ppa: jonathonf/python-2.7

third-party-python-repos-absent:
    cmd.run:
        - name: echo 'third party python repositories purged'
        - require:
            - dead-snakes-are-dead
            - jonothonf-is-missing

#
#
#

python-2.7:
    pkg.installed:
        - pkgs: 
            - python2.7
            - python-pip
        - require:
            - third-party-python-repos-absent

python-3.5:
    pkg.installed:
        - pkgs:
            - python3.5
            - python3-pip
            - python3.5-venv
        - require:
            - third-party-python-repos-absent

python-dev:
    pkg.installed:
        - pkgs:
            - python2.7-dev
            - python3.5-dev
            - libffi-dev 
            - libssl-dev
        - require:
            - python-2.7
            - python-3.5

global-python-requisites:
    pip.installed:
        #- pip_bin: /usr/bin/python2.7
        - pkgs:
            # DEPRECATED. installed for any remaining python 2 apps creating virtualenvs
            - virtualenv>=13
        - require:
            - python-2.7

{% else %}

# DEPRECATED. removed after switch to 16.04

# WARN: assumes python 2.7.12+ are already installed via bootstrap script

python-dev:
    pkg.installed:
        - pkgs:
            - python-dev
            - libffi-dev 
            - libssl-dev

global-python-requisites:
    cmd.run:
        # rmrf_enter is DEPRECATED
        # elife's delete script for stuff that accumulates
        - name: /usr/bin/python2.7 -m pip install virtualenv>=13 "git+https://github.com/elifesciences/rmrf_enter.git@master#egg=rmrf_enter" --no-cache-dir
        - require:
            - pkg: base

{% endif %}
