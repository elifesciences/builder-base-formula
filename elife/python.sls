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

python-2.7:
    pkg.installed:
        - name: python2.7
        # these don't work to upgrade if 'python2.7' already installed
        # and it's in the base box so this should never do anything
        #- refresh: True
        #- allow_updates: True
        #- reload_modules: True

python-dev:
    pkg.installed:
        - pkgs:
            - python-dev
            - libffi-dev 
            - libssl-dev

# https://github.com/saltstack/salt/issues/28036
python-pip:
    #pkg.installed
    cmd.run:
        - name: |
            curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && python get-pip.py

#python-pip:
#    pkg.removed:
#        - pkgs:
#            - python-pip
#            - python-pip-whl
#        - require_in:
#            - pkg: pip-shim

#pip-shim:
#    pip.installed:
#        - pkgs:
#            - setuptools
#
    #cmd.run:
    #    # issue with newer versions of pip
    #    # https://github.com/saltstack/salt/issues/33163
    #    - name: |
    #        easy_install "pip<=8.1.1"
    #        pip install --upgrade setuptools
    #    - require:
    #        - pkg: pip-shim
    ## https://github.com/saltstack/salt/issues/28036
    ## sacrificial state that does nothing except reload modules + fail silently
    #pip.installed:
    #    - name: pip
    #        #- "setuptools"
    #    - reload_modules: True
    #    - check_cmd:
    #        # fail silently
    #        - /bin/true
    #    - require:
    #        - cmd: pip-shim


global-python-requisites:

    pip.installed:
        - pkgs:
            - virtualenv>=13
            # rmrf_enter is DEPRECATED
            # elife's delete script for stuff that accumulates
            - "git+https://github.com/elifesciences/rmrf_enter.git@master#egg=rmrf_enter" 
        - require:
            - pkg: base
            - python-pip

{% endif %}
