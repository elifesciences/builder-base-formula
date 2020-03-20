{% set osrelease = salt['grains.get']('osrelease') %}

base:
    pkg.installed:
        - pkgs:
            - logrotate

            # todo@2019-12: obsolete, remove
            # deprecating. moving to upstart for 14.04
            # http://libslack.org/daemon/
            - daemon

            - curl
            - git
            - coreutils # includes 'realpath'
            - vim
            # also provides 'unzip'
            - zip
            # a nicer 'top'
            - htop

            # provides add-apt-repository binary needed to install a new ppa easily
            # renamed in 18.04
            {% if osrelease in ['16.04'] %}
            # depends on py2
            # https://packages.ubuntu.com/xenial/python-software-properties
            - python-software-properties
            {% else %}
            # depends on py3
            # https://packages.ubuntu.com/bionic/software-properties-common
            - software-properties-common 
            {% endif %}

            # find which files are taking up space on filesystem
            - ncdu
            # diagnosing disk IO 
            - sysstat # provides iostat
            - iotop

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
        - name: |
            set -e 
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

{% if osrelease not in ['16.04'] %}

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
{% endif %}
