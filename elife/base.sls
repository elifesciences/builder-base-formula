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

autoremove-orphans:
    cmd.run:
        - name: apt-get autoremove -y
        - env:
            - DEBIAN_FRONTEND: noninteractive
        - require:
            - base-purging
