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
            - docker-ce
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
        - source: https://github.com/docker/compose/releases/download/1.16.1/docker-compose-Linux-x86_64
        - source_hash: md5=0ed7666983387be3fd73d700c6627cdf
        - require:
            - docker-packages
    
    cmd.run:
        - name: chmod +x /usr/local/bin/docker-compose 
        - require:
            - file: docker-compose

docker-deploy-user-in-group:
    group.present:
        - name: docker
        - addusers:
            - {{ pillar.elife.deploy_user.username }}
        - require:
            - docker-packages
