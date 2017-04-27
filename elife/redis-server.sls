redis-server-install:
    pkg.installed:
        - pkgs:
            - redis-server

    file.managed:
        - name: /etc/redis/redis.conf
        - source: salt://elife/config/etc-redis-redis.conf
        - template: jinja
        - require:
            - pkg: redis-server-install
            - file: /var/run/redis
            - file: /var/log/redis-server.log
        - listen_in:
            - service: redis-server

redis-server:
    # /etc/init.d/redis-server is already provided by the package
    file.managed:
        - name: /etc/init.d/redis

    service.running:
        - require:
            - pkg: redis-server-install
            - file: redis-server-install
        - watch:
            - file: redis-server

/var/log/redis-server.log:
    file.managed:
        - user: redis
        - mode: 640

/var/run/redis:
    file.directory:
        - user: redis
        - group: redis
        - mode: 700
        - makedirs: True
