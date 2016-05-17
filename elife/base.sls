base:
    pkg.installed:
        - pkgs:
            - logrotate
            # deprecating. moving to upstart for 14.04
            # http://libslack.org/daemon/
            - daemon
            - curl
            - git
            # Ubuntu 14.04 bundles with X11 :(
            # - mercurial
            - vim
            # also provides 'unzip'
            - zip
            # a nicer 'top'
            - htop
            # provides add-apt-repository binary needed to install a new ppa easily
            - python-software-properties
            # installed as part of bootstrap for gitfs support, but worth mentioning again here.
            - python-dev 
            # find which files are taking up space on filesystem
            - ncdu 

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

base-vim-config:
    file.managed:
        - name: /etc/vim/vimrc
        - source: salt://elife/config/etc-vim-vimrc

