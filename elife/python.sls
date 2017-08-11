{% if salt['grains.get']('osrelease') == "16.04" %}

python-2.7:
    pkg.installed:
        - pkgs: 
            - python2.7
            - python-pip

python-3.5:
    pkg.installed:
        - pkgs:
            - python3.5
            #- python3-pip # python 3 has pip built in

python-dev:
    pkg.installed:
        - pkgs:
            - python2.7-dev
            - python3.5-dev
            - libffi-dev 
            - libssl-dev

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
#python-pip:
#    pkg.installed

python-pip:
    pkg.removed:
        - pkgs:
            - python-pip
            - python-pip-whl
        - require_in:
            - pip-shim

pip-shim:
    pkg.installed:
        - pkgs:
            - python-setuptools

    cmd.run:
        # issue with newer versions of pip
        # https://github.com/saltstack/salt/issues/33163
        - name: easy_install "pip<=8.1.1"
        - require:
            - pkg: pip-shim
    # https://github.com/saltstack/salt/issues/28036
    # sacrificial state that does nothing except reload modules + fail silently
    pip.installed:
        - name: "pip<=8.1.1"
        - reload_modules: True
        - check_cmd:
            # fail silently
            - /bin/true
        - require:
            - cmd: pip-shim


global-python-requisites:
    pip.installed:
        - pkgs:
            - virtualenv>=13
            # rmrf_enter is DEPRECATED
            # elife's delete script for stuff that accumulates
            - "git+https://github.com/elifesciences/rmrf_enter.git@master#egg=rmrf_enter" 
        - require:
            - pkg: base
            - pkg: python-pip

# pkgrepo for 2.7.12, should already be configured by builder's Salt bootstrap
# officially abandoned
python-2.7+:
    pkgrepo.managed:
        - humanname: Python 2.7 Updates
        - ppa: fkrull/deadsnakes-python2.7
        - require:
            - python-2.7
            - python-dev
            - global-python-requisites
        - unless:
            - test -e /etc/apt/sources.list.d/fkrull-deadsnakes-python2_7-trusty.list

{% endif %}
