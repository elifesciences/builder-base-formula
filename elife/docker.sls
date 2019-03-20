# fails on AWS, perhaps due to the package name
#docker-recommended-extra-packages:
#    cmd.run:
#        - name: |
#            sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual

docker-folder:
    file.directory:
        - name: /ext/docker
        - makedirs: True
        - mode: 711

docker-folder-linking:
    cmd.run:
        - name: |
            # to be compatible with both upstart and systemd
            stop docker || true
            systemctl stop docker || true
            # move files onto the volume
            mv /var/lib/docker/* /ext/docker
            rmdir /var/lib/docker
        - onlyif:
            # has something in it to move
            - ls -l /var/lib/docker/ | grep -v 'total 0'
            # is not a symlink already
            - test ! -L /var/lib/docker
        - require:
            - docker-folder

    file.symlink:
        - name: /var/lib/docker
        - target: /ext/docker
        - force: True
        - require:
            - cmd: docker-folder-linking

docker-gpg-key:
    cmd.run:
        - name: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

docker-repository:
    cmd.run:
        - name: sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        - require:
            - docker-gpg-key
            - docker-folder-linking

docker-packages:
    pkg.installed:
        - pkgs: 
            # poorly-patched vulnerability 'fix' breaks 3.3 kernels, like the one in the Ubuntu Trusty 14.04 LTS
            {% if salt['grains.get']('oscodename') == 'trusty' %}
            - docker-ce: 18.06.1~ce~3-0~ubuntu
            {% elif salt['grains.get']('oscodename') == 'xenial' %}
            - docker-ce: 18.09.3~3-0~ubuntu-xenial
            {% else %}
            # TODO: pin
            - docker-ce: 18.09.3
            {% endif %}
        - refresh: True
        - require:
            - docker-repository

    service.running:
        - name: docker
        - require:
            - pkg: docker-packages

docker-compose:
    file.managed:
        - name: /usr/local/bin/docker-compose 
        - source: https://github.com/docker/compose/releases/download/1.21.2/docker-compose-Linux-x86_64
        - source_hash: sha256=8a11713e11ed73abcb3feb88cd8b5674b3320ba33b22b2ba37915b4ecffdf042
        - require:
            - docker-packages
    
    cmd.run:
        - name: chmod +x /usr/local/bin/docker-compose 
        - require:
            - file: docker-compose

docker-users-in-group:
    group.present:
        - name: docker
        - addusers:
            - {{ pillar.elife.deploy_user.username }}
            - ubuntu
        - require:
            - docker-packages
            - ubuntu-user

docker-scripts:
    file.recurse:
        - name: /usr/local/docker-scripts/
        - source: salt://elife/docker-scripts
        - file_mode: 555

docker-scripts-path:
    file.managed:
        - name: /etc/profile.d/docker-scripts-path.sh
        - contents: export PATH=/usr/local/docker-scripts:$PATH
        - mode: 644
        - require: 
            - docker-scripts

docker-ready:
    cmd.run:
        - name: docker version
        - require:
            - docker-compose
            - docker-users-in-group
            - docker-scripts
            - docker-scripts-path

# frees disk space from old images/containers/volumes/...
# older than last X days hours and not in use
docker-prune-last-days:
    cmd.run:
        - name: /usr/local/docker-scripts/docker-prune {{ 24 * pillar.elife.docker.prune_days }}
        - require:
            - docker-ready

docker-prune-last-days-cron:
    cron.present:
        - identifier: docker-prune-last-days
        - name: /usr/local/docker-scripts/docker-prune {{ 24 * pillar.elife.docker.prune_days }}
        - minute: random
        - require:
            - docker-ready
