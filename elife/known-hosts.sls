#
# SSH system-wide known hosts
#

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
github.com:
    ssh_known_hosts.present:
        - key: uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s
        - enc: ssh-rsa
        - unless:
            - grep "ssh-rsa uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s" /etc/ssh/ssh_known_hosts


{% for key in pillar.elife.known_hosts %}
known-hosts-{{ key }}:
    ssh_known_hosts.present:
        - name: {{ pillar.elife.known_hosts[key].host }}
        - fingerprint: {{ pillar.elife.known_hosts[key].fingerprint }}
        - fingerprint_hash_type: md5
        - enc: {{ pillar.elife.known_hosts[key].get("enc", "ssh-rsa") }}
        - timeout: {{ pillar.elife.known_hosts[key].get("timeout", 10) }}
        - unless:
            - grep -r "^{{ pillar.elife.known_hosts[key].host }}," /etc/ssh/ssh_known_hosts
{% endfor %}

/etc/ssh/ssh_known_hosts:
    file.exists:
        - require:
            - ssh_known_hosts: github.com
