{% set osrelease = salt['grains.get']('osrelease') %}

# salt regularly drops support for older salt releases. this makes apt fail.
remove-salt-source-file:
    file.absent:
        - name: /etc/apt/sources.list.d/saltstack.list

base:
    pkg.installed:
        - require:
            - remove-salt-source-file
        - pkgs:
            - logrotate
            - curl
            - git
            - coreutils # includes 'realpath'
            - vim
            # also provides 'unzip'
            - zip
            # a nicer 'top'
            - htop

            # provides add-apt-repository binary needed to install a new ppa easily
            # - https://packages.ubuntu.com/bionic/software-properties-common
            - software-properties-common

            # find which files are taking up space on filesystem
            - ncdu
            # diagnosing disk IO 
            - sysstat # provides iostat
            - iotop
            
            {% if osrelease != "18.04" %}
            
            - ripgrep # aka 'rg'
            - fd-find # aka 'fd'
            
            {% endif %}

            # useful for smoke testing the JSON output
            - jq

            # for tab-completion of bash commands
            # present on EC2 AMIs but not Vagrant bento images. this makes it consistent
            - bash-completion

base-purging:
    pkg.purged:
        - pkgs:
            - puppet
            - snapd
        - require:
            - base

{% if osrelease != "18.04" %}

# make 'fdfind' just 'fd'
symlink fdfind to fd:
    file.symlink:
        - name: /usr/bin/fd
        - target: /usr/bin/fdfind
        - require:
            - base
{% endif %}

system-git-config:
    file.managed:
        - name: /etc/gitconfig
        - source: salt://elife/config/etc-gitconfig

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
        # 'clean' clears out the local repository of retrieved package files.
        # 'autoclean' clears out the local repository of retrieved package files. 
        # The difference is that it only removes package files that can no longer be downloaded
        # 'autoremove' is used to remove packages that were automatically installed to satisfy dependencies 
        # for other packages and are now no longer needed.
        - name: |
            set -e
            apt-get clean -y
            apt-get autoremove -y
            apt-get autoclean -y
        - env:
            - DEBIAN_FRONTEND: noninteractive
        - require:
            - base-purging

systemd-dir-exists:
    file.directory:
        - name: /lib/systemd/system/
        - makedirs: True

.bashrc-template:
    file.managed:
        - name: /etc/skel/.bashrc
        - source: salt://elife/config/etc-skel-.bashrc
        - template: jinja

# lsh@2020-03: the root user's .bashrc file isn't sourced from /etc/skel/.bashrc like 
# regular users. The two are very very similar with no functional differences but at 
# some point they started diverging. This is *not* a temporary state.
root-user:
    file.managed:
        - name: /root/.bashrc
        - source: salt://elife/config/etc-skel-.bashrc
        - template: jinja

ubuntu-user:
    user.present: 
        - name: ubuntu
        - shell: /bin/bash
        - groups:
            - sudo
        - require:
            - .bashrc-template

    # lsh@2020-03: temporary state, remove when:
    # - all users on all machines (stopped and running) have been updated, or
    # - all ec2 instances have been replaced
    file.managed:
        - name: /home/ubuntu/.bashrc
        - source: salt://elife/config/etc-skel-.bashrc
        - template: jinja
        - require:
            - user: ubuntu-user

# unnecessary always-on new container service introduced in 18.04
# used by a new and unasked-for instance monitoring agent from AWS

amazon-ssm-agent-snap-removal:
    cmd.run:
        - name: snap remove amazon-ssm-agent
        - onlyif:
            - hash snap

snapd:
    service.dead:
        - enable: False
        - onlyif:
            - hash snap
        - require:
            - amazon-ssm-agent-snap-removal

    cmd.run:
        - name: rm -rf /var/cache/snapd
        - require:
            - service: snapd
        - require_in:
            - pkg: base-purging

disable-ubuntu-motd-news:
    file.managed:
        - name: /etc/default/motd-news
        - source: salt://elife/config/etc-default-motd-news
        - mode: 0644

