# elife projects depend on this user existing.
# the deploy user is used to clone app repos and access configured machines.

{% set user = pillar.elife.deploy_user.username %}

sudo-group:
    group.present:
        - name: sudo
        - system: True

deploy-user:
    user.present: 
        - name: {{ user }}
        - shell: /bin/bash
        - groups:
            - sudo
            - mail
        - require:
            - group: sudo-group

/home/{{ user }}/.ssh/:
    file.directory:
        - user: {{ user }}
        - group: {{ user }}
        - dir_mode: 755

    cmd.run:
        - user: {{ user }}
        # the empty double quote is the "no passphrase" switch
        - name: ssh-keygen -t rsa -f /home/{{ user }}/.ssh/id_rsa -N ""
        - unless:
            - test -f /home/{{ user }}/.ssh/id_rsa
        - require:
            - file: /home/{{ user }}/.ssh/
            - user: deploy-user

/etc/sudoers.d/90-salt-users:
    file.managed:
        - source: salt://elife/config/etc-sudoers.d-90saltusers
        - mode: 440
        - template: jinja
