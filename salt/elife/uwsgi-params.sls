uwsgi-params:
    file.managed:
        - name: /etc/uwsgi/params
        - makedirs: True
        - source: salt://elife/config/etc-uwsgi-params
