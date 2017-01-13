utils-scripts:
    file.recurse:
        - name: /usr/local/utils/
        - source: salt://elife/utils
        - file_mode: 555

utils-scripts-path:
    file.managed:
        - name: /etc/profile.d/utils-path.sh
        - source: salt://elife/config/etc-profile.d-utils-path.sh
        - mode: 644

utils-packages:
    pkg.installed:
        - pkgs:
            # useful for smoke testing the JSON output
            - jq
