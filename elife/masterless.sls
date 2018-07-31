#
# only included for masterless instances
#

# when running salt masterless, minion doesn't need to run as a daemon
disable-salt-minion:
    service.dead:
        - name: salt-minion
        - enable: false

# deny access to all except those in allow.all and allow.master-server
# necessary to ensure those with access don't inadvertently grant access to others

{% set stackname = salt['elife.cfg']('project.stackname') | replace('-', '\-') %}

# zero out all allowed keys
deny_all_access:
    cmd.run:
        - name: |
            set -e
            echo > /home/elife/.ssh/authorized_keys
            cat /home/ubuntu/.ssh/authorized_keys | grep "{{ stackname }}" > tmp
            mv tmp /home/ubuntu/.ssh/authorized_keys
        - require:
            - ssh-access-set # regular permissions configured

# allow

{% set ssh = pillar.elife.ssh_access %}

{% set allowed = ssh.allowed.get('master-server', []) + ssh.allowed.get("all", []) %}
{% for username in allowed %}
    {% if pillar.elife.ssh_users.has_key(username) %}

masterless-ssh-access-for-{{ username }}:
    ssh_auth.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - deny_all_access
        - require_in:
            - cmd: masterless-ssh-access
    {% endif %}
{% endfor %}

masterless-ssh-access:
    cmd.run:
        - name: echo "masterless ssh access set"

# deny 

{% set denied = ssh.denied.get("master-server", []) + ssh.denied.get("all", []) %}

{% for username in denied %}
    {% if pillar.elife.ssh_users.has_key(username) %}

masterless-ssh-denial-for-{{ username }}:
    ssh_auth.absent:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - masterless-ssh-access
        - require_in:
            - cmd: masterless-ssh-configured
            
masterless-ssh-denial-for-{{ username }}-using-{{ pillar.elife.bootstrap_user.username }}:
    ssh_auth.absent:
        - user: {{ pillar.elife.bootstrap_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - masterless-ssh-access
        - require_in:
            - cmd: masterless-ssh-configured
            
    {% endif %}
{% endfor %}

masterless-ssh-configured:
    cmd.run:
        - name: echo "all ssh access and access denials set for masterless instance"

