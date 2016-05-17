base:
    pkg.installed:
        - pkgs:
            - logrotate
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
    cmd.run:
        - name: easy_install pip

global-python-requisites:
    pip.installed:
        - pkgs:
            - virtualenv>=13
            # elife's delete script for stuff that accumulates
            - "-e git+https://github.com/elifesciences/rmrf_enter.git@master#egg=rmrf_enter" 
        - require:
            - pkg: base

base-vim-config:
    file.managed:
        - name: /etc/vim/vimrc
        - source: salt://elife/config/etc-vim-vimrc

