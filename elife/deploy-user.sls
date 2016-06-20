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

#
# ssh allow/deny access
#

{% set pname = salt['elife.project_name']() %}
{% set ssh = pillar.elife.ssh_access %}

# allow

{% for username in ssh.allowed.get(pname, []) %}
    {% if pillar.elife.ssh_users.has_key(username) %}

{{ pname }}-ssh-access-for-{{ username }}:
    ssh_auth.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/

    {% endif %}
{% endfor %}

# deny

{% for username in ssh.denied.get(pname, []) %}
    {% if pillar.elife.ssh_users.has_key(username) %}

{{ pname }}-ssh-denial-for-{{ username }}:
    ssh_auth.absent:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/

    {% endif %}
{% endfor %}

