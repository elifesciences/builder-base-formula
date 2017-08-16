# only included for masterless instances


# when running salt masterless, minion doesn't need to run as a daemon
disable-salt-minion:
    service.dead:
        - name: salt-minion
        - enable: false
        - onlyif:
            # running within vagrant
            - test -d /vagrant



# deny access to all except those in allow.all and allow.master-server
# necessary to ensure those with access don't inadvertently grant access to others

# zero out all allowed keys
deny_all_access:
    cmd.run:
        - name: |
            echo > /home/elife/.ssh/authorized_keys
            # bootstrap user is needed to login
            # masterless environment disables adding any other keys to bootstrap user
            #echo > /home/ubuntu/.ssh/authorized_keys

# allow

{% set allowed = ssh.allowed.get('master-server', []) + ssh.allowed.get("all", []) %}
{% for username in allowed %}
    {% if pillar.elife.ssh_users.has_key(username) %}

masterless-ssh-access-for-{{ username }}:
    ssh_auth.present:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/
    {% endif %}
{% endfor %}

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
            - cmd: /home/{{ user }}/.ssh/
            
masterless-ssh-denial-for-{{ username }}-using-{{ pillar.elife.bootstrap_user.username }}:
    ssh_auth.absent:
        - user: {{ pillar.elife.bootstrap_user.username }}
        - name: {{ pillar.elife.ssh_users[username] }}
        - comment: {{ username }}
        - require:
            - cmd: /home/{{ user }}/.ssh/
            
    {% endif %}
{% endfor %}

