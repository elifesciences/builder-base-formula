# originally used to obviate to Route53 downtime
{% for hostname, ip_address in pillar.elife.forced_dns.iteritems() %}
{% if ip_address %}
forced-dns-entries-add-{{ hostname }}:
    file.append:
        - name: /etc/hosts
        - text:
            - "{{ ip_address }} {{ hostname }}"
{% else %}
forced-dns-entries-remove-{{ hostname }}:
    file.replace:
        - name: /etc/hosts
        - pattern: "^[0-9\.]* {{ hostname }}$"
        - repl: ""
{% endif %}
{% endfor %}
