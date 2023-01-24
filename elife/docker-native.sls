{% set osrelease = salt['grains.get']('osrelease') %}
{% set oscodename = salt['grains.get']('oscodename') %}
{% set ext_path = pillar.elife.external_volume.directory %}

docker-folder:
    file.directory:
        # "/ext/docker", "/bot-tmp/docker"
        - name: {{ ext_path }}/docker
        - makedirs: True
        - mode: 711

docker-folder-linking:
    cmd.run:
        - name: |
            systemctl stop docker.socket
            systemctl stop docker
            # move files onto the volume
            mv /var/lib/docker/* {{ ext_path }}/docker
            rmdir /var/lib/docker
        - onlyif:
            # dir exists (also true if path is a symlink)
            - test -d /var/lib/docker
            # is not a symlink already (also true if path doesn't exist)
            - test ! -L /var/lib/docker
            # has something in it to move
            - ls -l /var/lib/docker/ | grep -v 'total 0'
        - require:
            - docker-folder

    file.symlink:
        - name: /var/lib/docker
        - target: {{ ext_path }}/docker
        - force: True
        - require:
            - cmd: docker-folder-linking

docker-packages:
    # we need a version greater than '18.09.3' but can't specify that with a wildcard (*).
    # https://github.com/moby/moby/issues/38249#issuecomment-474795342
    pkg.installed:
        - name: docker.io
        - refresh: True
        - require:
            - docker-folder-linking

    service.running:
        - name: docker
        - require:
            - pkg: docker-packages

docker-compose:
    file.managed:
        - name: /usr/local/bin/docker-compose 
        - source: https://github.com/docker/compose/releases/download/1.24.0/docker-compose-Linux-x86_64
        - source_hash: sha256=bee6460f96339d5d978bb63d17943f773e1a140242dfa6c941d5e020a302c91b
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
