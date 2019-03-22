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

            - vim
            # also provides 'unzip'
            - zip
            # a nicer 'top'
            - htop

            # provides add-apt-repository binary needed to install a new ppa easily
            # renamed in 18.04
            {% if codename != 'bionic' %}
            - python-software-properties
            {% else %}
            - software-properties-common 
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

# unnecessary always-on new container service in 18.04 that nothing uses
snapd:
    service.dead:
        - enable: False
        - onlyif:
            - hash snap
