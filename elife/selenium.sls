xvfb:
    pkg:
        - installed
    file.managed:
        - name: /etc/init.d/xvfb
        - source: salt://elife/config/etc-init.d-xvfb
        - mode: 755
    service.running:
        - enable: True
        - watch:
              - file: xvfb
        - require:
              - pkg: xvfb
              - file: xvfb

firefox-ppa:
    pkgrepo.managed:
      - humanname: Mozilla PPA that has all versions of Firefox
      - name: deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main
      - file: /etc/apt/sources.list.d/firefox-mozilla.list
      - keyid: C1289A29
      - keyserver: keyserver.ubuntu.com

# cannot actually install an old version from PPA, downloading a deb
firefox-pinned-version:
    cmd.run:
        - name: |
            wget -O firefox-48.deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt/pool/main/f/firefox-mozilla-build/firefox-mozilla-build_48.0.2-0ubuntu1_amd64.deb
            dpkg -i firefox-48.deb
        - cwd: /root
        - require:
            - firefox-ppa

selenium-server:
    file.managed:
        - name: /usr/bin/selenium-server-standalone.jar
        - source: https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar
        - source_hash: md5=63a0b96eab18f8420b9bba2f0f5d380c

# runs as root for now
selenium-log:
    file.managed:
        - name: /var/log/selenium.log

selenium:
    file.managed:
        - name: /etc/init.d/selenium
        - source: salt://elife/config/etc-init.d-selenium
        - mode: 755
    service.running:
        - enable: True
        - watch:
              - file: selenium-server
              - file: selenium
        - require:
              - pkg: openjdk7-jre
              - file: selenium-server
              - file: selenium
              - service: xvfb
