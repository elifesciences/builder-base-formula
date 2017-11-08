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
    cmd.run:
        - name: |
            curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose 
        - unless:
            - docker-compose
        - require:
            - docker-packages


