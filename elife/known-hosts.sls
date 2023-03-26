#
# SSH system-wide known hosts
#

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
github.com:
    ssh_known_hosts.present:
        - fingerprint: uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s
        - enc: ssh-rsa
        - unless:
            - grep "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=" /etc/ssh/ssh_known_hosts


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
