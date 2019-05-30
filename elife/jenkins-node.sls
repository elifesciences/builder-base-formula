libraries-runner-directory:
    file.directory:
        - name: /ext/jenkins-libraries-runner
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - dir_mode: 755
        - require:
            - deploy-user
            - mount-external-volume

# to get all environment variables like PATH
# when executing commands over SSH (which is what Jenkins does
# to start the slave)
{% for user in [pillar.elife.deploy_user.username, 'ubuntu'] %}
jenkins-bashrc-sourcing-profile-user-{{ user }}:
    file.prepend:
        - name: /home/{{ user }}/.bashrc
        - text:
            - "# to load PATH and env variables in all ssh commands"
            - source /etc/profile
        - require:
            - deploy-user
{% endfor %}

jenkins-slave-node-folder:
    file.symlink:
        - name: /var/lib/jenkins-libraries-runner
        - target: /ext/jenkins-libraries-runner
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - libraries-runner-directory

# to check out projects on the slave
# the paths are referring to /var/lib/jenkins because it's the path on the master

add-alfred-private-key-to-deploy-user:
    file.managed:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /home/{{ pillar.elife.deploy_user.username }}/.ssh/id_rsa
        - source: salt://elife-alfred/config/var-lib-jenkins-.ssh-id_rsa
        - mode: 400
        - require:
            - deploy-user

add-alfred-public-key-to-deploy-user:
    file.managed:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /home/{{ pillar.elife.deploy_user.username }}/.ssh/id_rsa.pub
        - source: salt://elife-alfred/config/var-lib-jenkins-.ssh-id_rsa.pub
        - mode: 400
        - require:
            - deploy-user

# Jenkins slave does not clean up workspaces after builds are run.
# Cleaning them manually while no build should be running is
# necessary to avoid filling up the disk space or inodes
jenkins-workspaces-cleanup-cron:
    cron.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: rm -rf /var/lib/jenkins-libraries-runner/workspace/*
        - identifier: clean-workspaces
        - hour: 5
        - minute: 0

add-jenkins-gitconfig-deploy-user:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.gitconfig
        - source: salt://elife/config/home-deploy-user-.gitconfig
        - mode: 664

add-jenkins-gitconfig-ubuntu-user:
    file.managed:
        - name: /home/ubuntu/.gitconfig
        - source: salt://elife/config/home-deploy-user-.gitconfig
        - mode: 664
