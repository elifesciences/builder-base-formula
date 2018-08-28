{% set codename = salt['grains.get']('oscodename') %}

base:
    pkg.installed:
        - pkgs:
            - logrotate
            # deprecating. moving to upstart for 14.04
            # http://libslack.org/daemon/
            - daemon
            - curl
            - git
            {% if codename == "trusty" %}
            - realpath # resolves symlinks in paths for shell
            {% endif %}
            - coreutils # includes realpath
            # Ubuntu 14.04 bundles with X11 :(
            # - mercurial
            - vim
            # also provides 'unzip'
            - zip
            # a nicer 'top'
            - htop
            # provides add-apt-repository binary needed to install a new ppa easily
            {% if codename == 'bionic' %}
            - software-properties-common # renamed in 18.04
            {% else %}
            - python-software-properties
            {% endif %}
            # find which files are taking up space on filesystem
            - ncdu
            # diagnosing disk IO 
            - sysstat # provides iostat
            - iotop

base-purging:
    pkg.purged:
        - pkgs:
            - puppet

base-vim-config:
    file.managed:
        - name: /etc/vim/vimrc
        - source: salt://elife/config/etc-vim-vimrc

base-updatedb-config:
    file.managed:
        - name: /etc/updatedb.conf
        - source: salt://elife/config/etc-updatedb.conf

autoremove-orphans:
    cmd.run:
        - name: apt-get autoremove -y
        - env:
            - DEBIAN_FRONTEND: noninteractive
        - require:
            - base-purging

systemd-dir-exists:
    file.directory:
        - name: /lib/systemd/system/
        - makedirs: True

ubuntu-user:
    user.present: 
        - name: ubuntu
        - shell: /bin/bash
        - groups:
            - sudo
