environment-name:
    file.managed:
        - name: /etc/profile.d/environment-name.sh
        - source: salt://elife/config/etc-profile.d-environment-name.sh
        - template: jinja
        - mode: 644
