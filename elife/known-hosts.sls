#
# SSH system-wide known hosts
#

github.com:
    ssh_known_hosts.present:
        - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
        - enc: ssh-rsa
        - unless:
            - grep -r "^github.com," /etc/ssh/ssh_known_hosts


{% for key in pillar.elife.known_hosts %}
known-hosts-{{ key }}:
    ssh_known_hosts.present:
        - name: {{ pillar.elife.known_hosts[key].host }}
        - fingerprint: {{ pillar.elife.known_hosts[key].fingerprint }}
        - enc: {{ pillar.elife.known_hosts[key].get("enc", "ssh-rsa") }}
        - timeout: {{ pillar.elife.known_hosts[key].get("timeout", 10) }}
        - unless:
            - grep -r "^{{ pillar.elife.known_hosts[key].host }}," /etc/ssh/ssh_known_hosts
{% endfor %}

/etc/ssh/ssh_known_hosts:
    file.exists:
        - require:
            - ssh_known_hosts: github.com
            - ssh_known_hosts: bitbucket.org
