{% for folder in pillar.elife.nginx_public_folders %}
nginx-public-folders-{{ folder }}:
    file.directory:
        - name: /var/nginx-public-folders/{{ folder }}
        - mode: 777
        - makedirs: True
        - require_in:
            - file: nginx-public-folders-vhost
{% endfor %}

nginx-public-folders-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/public-folders.conf
        - source: salt://elife/config/etc-nginx-sites-enabled-public-folders.conf
        - template: jinja
        - listen_in:
            - service: nginx-server-service
