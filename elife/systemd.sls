/etc/systemd/journald.conf:
    file.replace:
        - pattern: "^#?SystemMaxUse=.*"
        - repl: "SystemMaxUse=100M"

systemd-journald:
    service.running:
        - enable: True
        - watch:
            - file: /etc/systemd/journald.conf
