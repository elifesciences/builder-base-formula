{% set osrelease = salt['grains.get']('osrelease') %}

base:
    pkg.installed:
        - pkgs:
            - logrotate
            # deprecating. moving to upstart for 14.04
            # http://libslack.org/daemon/
            - daemon
            - curl
            - git

            {% if osrelease == "14.04" %}
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
            {% if osrelease in ['14.04', '16.04'] %}
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
            - snapd

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

{% if osrelease not in ['14.04', '16.04'] %}

# a new, unasked-for, instance monitoring agent from Amazon in 18.04 images
amazon-ssm-agent-snap-removal:
    cmd.run:
        - name: snap remove amazon-ssm-agent
        - onlyif:
            - hash snap

# unnecessary always-on new container service in 18.04 that nothing uses
snapd:
    service.dead:
        - enable: False
        - onlyif:
            - hash snap
        - require:
            - amazon-ssm-agent-snap-removal
        - require_in:
            - base-purging
{% endif %}
