#
# SSH system-wide known hosts
#

{% set old_github_key = "AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" %}

{% for path in [
    "/etc/ssh/ssh_known_hosts",
    "/home/elife/.ssh/known_hosts",
    "/root/.ssh/known_hosts"]
%}
remove-old-github.com-key-in-{{ path }}:
    file.line:
        - name: {{ path }}
        - mode: delete
        - match: {{ old_github_key }}
        - require_in:
            - cmd: remove-old-github.com-key
        - onlyif:
            - test -f {{ path }}
{% endfor %}

remove-old-github.com-key:
    cmd.run:
        - name: echo "done"

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
# fingerprint must be in hex form:
# - https://github.com/saltstack/salt/issues/46152#issuecomment-625592695
github.com:
    ssh_known_hosts.present:
        - fingerprint: b8:d8:95:ce:d9:2c:0a:c0:e1:71:cd:2e:f5:ef:01:ba:34:17:55:4a:4a:64:80:d3:31:cc:c2:be:3d:ed:0f:6b
        - hash_known_hosts: false
        - enc: ssh-rsa
        - unless:
            - grep "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=" /etc/ssh/ssh_known_hosts
        - require:
            - remove-old-github.com-key

# lsh@2023-03-27: turns out "ssh-keygen -R ..." changes file permissions to 600
# this prevented requests from discovering updated github.com host keys.
/etc/ssh/ssh_known_hosts:
    file.managed:
        - mode: 0644
        - require:
            - github.com

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


