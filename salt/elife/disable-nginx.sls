# stops and disables nginx only, does not uninstall.

nginx-server-service:
    service.dead:
        - name: nginx
        - enable: false
