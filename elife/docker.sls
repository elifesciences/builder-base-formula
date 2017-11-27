# fails on AWS, perhaps due to the package name
#docker-recommended-extra-packages:
#    cmd.run:
#        - name: |
#            sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual

docker-gpg-key:
    cmd.run:
        - name: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

docker-repository:
    cmd.run:
        - name: sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        - require:
            - docker-gpg-key

docker-packages:
    pkg.installed:
        - pkgs: 
            - docker-ce
        - refresh: True
        - require:
            - docker-repository

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
