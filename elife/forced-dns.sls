# originally used to obviate to Route53 downtime
{% for hostname, ip_address in pillar.elife.forced_dns.iteritems() %}
forced-dns-entries-{{ hostname }}:
    file.append:
        - name: /etc/sudoers
        - text:
            - "{{ ip_address }} {{ hostname }}"
{% endfor %}
