python-2.7+:
    pkgrepo.managed:
        - humanname: Python 2.7 Updates
        - ppa: fkrull/deadsnakes-python2.7

    pkg.installed:
        - name: python2.7
        # these don't work to upgrade if 'python2.7' already installed
        #- refresh: True
        #- allow_updates: True
        - require:
            - pkgrepo: python-2.7+

    # this does upgrade it, but new python isn't available during rest of highstate
    cmd.run:
        - name: apt-get install python2.7 -y
        # might work?
        - reload_modules: True
        - require:
            - pkg: python-2.7+

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
            # elife's delete script for stuff that accumulates
            - "git+https://github.com/elifesciences/rmrf_enter.git@master#egg=rmrf_enter" 
        - require:
            - pkg: base
            - pkg: python-pip
