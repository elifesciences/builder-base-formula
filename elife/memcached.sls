memcached:
    pkg.installed

memcached-config:
    file.managed:
        - name: /etc/memcached.conf
        - source: salt://elife/etc-memcached.conf
