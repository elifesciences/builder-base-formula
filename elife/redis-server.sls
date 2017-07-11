{% set on_elasticache = salt['elife.cfg']('cfn.outputs.ElastiCacheHost') %}

{% if not on_elasticache %}
redis-packages-install:
    pkg.installed:
        - pkgs:
            - redis-server
            - redis-tools

    file.managed:
        - name: /etc/redis/redis.conf
        - source: salt://elife/config/etc-redis-redis.conf
        - template: jinja
        - require:
            - pkg: redis-packages-install
            - file: /var/run/redis
            - file: /var/log/redis-server.log
        - listen_in:
            - service: redis-server

{% else %}
redis-packages-install:
    pkg.installed:
        - pkgs:
            - redis-tools # includes redis-cli
{% endif %}

{% if not on_elasticache %}
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

redis-server:
    service.running:
        - require:
            - redis-packages-install
            - /var/run-redis
            - /var/log/redis-server.log
        - watch:
            - file: redis-server

{% else %}
redis-server:
    cmd.run:
        - name: echo "Redis is on a separate ElastiCache server"
{% endif %}
