xvfb:
    pkg:
        - installed
    file.managed:
        - name: /etc/init.d/xvfb
        - source: salt://elife/config/etc-init.d-xvfb
        - mode: 755
    service.running:
        - watch:
              - file: xvfb
        - require:
              - pkg: xvfb
              - file: xvfb

firefox:
    pkg.installed:
        - refresh: True

selenium-server:
    file.managed:
        - name: /usr/bin/selenium-server-standalone.jar
        - source: https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar
        - source_hash: md5=63a0b96eab18f8420b9bba2f0f5d380c

selenium:
    file.managed:
        - name: /etc/init.d/selenium
        - source: salt://elife/config/etc-init.d-selenium
        - mode: 755
    service.running:
        - watch:
              - file: selenium-server
              - file: selenium
        - require:
              - pkg: openjdk7-jre
              - file: selenium-server
              - file: selenium
              - service: xvfb
