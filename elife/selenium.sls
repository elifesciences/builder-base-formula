xvfb:
    pkg:
        - installed
    file.managed:
        - name: /etc/init.d/xvfb
        - source: salt://elife/config/etc-init.d-xvfb
        - mode: 755

firefox:
    pkg:
        - installed

get-selenium:
    cmd.run:
        - cwd: /usr/bin
        - name: wget http://selenium-release.storage.googleapis.com/2.46/selenium-server-standalone-2.46.0.jar > /dev/null
        - unless:
            - test -f /usr/bin/selenium-server-standalone-2.46.0.jar
    file.managed:
        - name: /etc/init.d/selenium
        - source: salt://elife/config/etc-init.d-selenium
        - mode: 755
