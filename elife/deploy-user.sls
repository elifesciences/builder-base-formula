# elife projects depend on this user existing.
# the deploy user is used to clone app repos and access configured machines.

{% set user = pillar.elife.deploy_user.username %}

sudo-group:
    group.present:
        - name: sudo
        - system: True
        - addusers:
            - ubuntu
        - require:
            - ubuntu-user

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
        - runas: {{ user }}
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

vagrant-user:
    ssh_auth.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - source: /vagrant/custom-vagrant/id_rsa.pub
        - onlyif:
            - test -e /vagrant/custom-vagrant/id_rsa.pub

# allow

{% set allowed = ssh.allowed.get(pname, []) + ssh.allowed.get("all", []) %}

{% for username in allowed %}
    {% if username in pillar.elife.ssh_users %}

{{ pname }}-ssh-access-for-{{ username }}:
    ssh_auth.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/
        - require_in:
            - cmd: ssh-access-set

        {% if pillar.elife.ssh_access.also_bootstrap_user %}

{{ pname }}-ssh-access-for-{{ username }}-using-{{ pillar.elife.bootstrap_user.username }}:
    ssh_auth.present:
        - user: {{ pillar.elife.bootstrap_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/
        - require_in:
            - cmd: ssh-access-set

        {% endif %}

    {% endif %}
{% endfor %}

# deny

{% set denied = ssh.denied.get(pname, []) + ssh.denied.get("all", []) %}

{% for username in denied %}
    {% if username in pillar.elife.ssh_users %}

{{ pname }}-ssh-denial-for-{{ username }}:
    ssh_auth.absent:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/
        - require_in:
            - cmd: ssh-access-set
            
{{ pname }}-ssh-denial-for-{{ username }}-using-{{ pillar.elife.bootstrap_user.username }}:
    ssh_auth.absent:
        - user: {{ pillar.elife.bootstrap_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/
        - require_in:
            - cmd: ssh-access-set
            
    {% endif %}
{% endfor %}

ssh-access-set:
    cmd.run:
        - name: echo "all ssh access and access denials set"

