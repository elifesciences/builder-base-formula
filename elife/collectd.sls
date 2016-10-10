collectd:
{% if pillar.elife.logging.collectd.enabled %}
    cmd.run:
        # installation fails out of the box for some reason
        - name: apt-get install collectd --no-install-recommends -y || true
        - unless:
            - dpkg -l | grep -i collectd

    file.managed:
        - name: /etc/collectd/collectd.conf
        - source: salt://elife/config/etc-collectd-collectd.conf
        - template: jinja
        - mode: 644
        - require:
            - cmd: collectd

    service.running:
        - require:
            - cmd: collectd
            - file: collectd
        - watch:
            - file: collectd
{% else %}
    pkg.removed:
        - pkgs:
            - collectd
            - collectd-core
{% endif %}
