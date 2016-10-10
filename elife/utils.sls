utils-scripts:
    file.recurse:
        - name: /usr/local/utils/
        - source: salt://elife/utils
        - file_mode: 555

utils-scripts-path:
    file.managed:
        - name: /etc/profile.d/utils-path.sh
        - contents: |
            export PATH=/usr/local/utils:$PATH
        - mode: 644
