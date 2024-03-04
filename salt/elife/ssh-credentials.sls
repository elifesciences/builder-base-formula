{% for _key, entry in pillar.elife.ssh_credentials.items() %}
ssh-credentials-{{ entry['username'] }}-folder:
    file.directory:
        - user: {{ entry['username'] }}
        - group: {{ entry['username'] }}
        - name: {{ entry['home'] }}/.ssh
        - dir_mode: 750
        - makedirs: True

ssh-credentials-{{ entry['username'] }}-remove-leftover-public-keys:
    file.absent:
        - name: {{ entry['home'] }}/.ssh/id_rsa.pub
        - require:
            - ssh-credentials-{{ entry['username'] }}-folder

ssh-credentials-{{ entry['username'] }}-private-key:
    file.managed:
        - user: elife
        - name: {{ entry['home'] }}/.ssh/id_rsa
        - source: {{ entry['private_key'] }}
        - mode: 400
        - require:
            - ssh-credentials-{{ entry['username'] }}-remove-leftover-public-keys
{% endfor %}
