# originally used to obviate to Route53 downtime
{% for hostname, ip_address in pillar.elife.forced_dns.iteritems() %}
{% if ip_address %}
forced-dns-entries-{{ hostname }}:
    file.append:
        - name: /etc/hosts
        - text:
            - "{{ ip_address }} {{ hostname }}"
{% else %}
forced-dns-entries-{{ hostname }}:
    file.replace:
        - name: /etc/hosts
        - pattern: "^{{ ip_address }} "
        - repl: ""
{% endif %}
{% endfor %}
