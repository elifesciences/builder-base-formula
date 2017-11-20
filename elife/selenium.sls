xvfb:
    pkg:
        - installed

    file.managed:
        {% if not salt['grains.get']('osrelease') == "16.04" %}
        - name: /etc/init.d/xvfb
        - source: salt://elife/config/etc-init.d-xvfb
        - mode: 755
        {% else %}
        - name: /lib/systemd/system/xvfb.service
        - source: salt://elife/config/lib-systemd-system-xvfb.service
        - mode: 644
        {% endif %}

    service.running:
        - enable: True
        - watch:
              - file: xvfb
        - require:
              - pkg: xvfb
              - file: xvfb

firefox-ppa-doesnt-work:
    file.absent:
      - name: /etc/apt/sources.list.d/firefox-mozilla.list

firefox-dependencies:
    pkg.installed:
        - pkgs:
            - libgtk-3-0

# cannot actually install an old version from PPA, downloading a deb
firefox-pinned-version:
    cmd.run:
        - name: |
            wget -c -O firefox-47.deb http://s3.amazonaws.com/elife-builder/packages/firefox-47.deb
            dpkg -i firefox-47.deb
        - cwd: /root
        - require:
            - firefox-dependencies
        - unless:
            - test "`firefox -v`" = "Mozilla Firefox 47.0.1"

firefox-headless-multimedia:
    pkg.installed:
        - pkgs:
            - mplayer
            - linux-sound-base

    cmd.run:
        - name: sudo apt-get -y install linux-image-extra-$(uname -r)
        - require:
            - pkg: firefox-headless-multimedia

    kmod.present:
        - name: snd_dummy
        - persist: True
        - require:
            - cmd: firefox-headless-multimedia


selenium-server:
    file.managed:
        - name: /usr/bin/selenium-server-standalone.jar
        - source: https://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar
        - source_hash: md5=63a0b96eab18f8420b9bba2f0f5d380c

# runs as root for now
selenium-log:
    file.managed:
        - name: /var/log/selenium.log

selenium-logrotate:
    file.managed:
        - name: /etc/logrotate.d/selenium
        - source: salt://elife/config/etc-logrotate.d-selenium
        - require:
            - selenium-log

selenium:
    file.managed:
        {% if not salt['grains.get']('osrelease') == "16.04" %}
        - name: /etc/init.d/selenium
        - source: salt://elife/config/etc-init.d-selenium
        - mode: 755
        {% else %}
        - name: /lib/systemd/system/selenium.service
        - source: salt://elife/config/lib-systemd-system-selenium.service
        - mode: 644
        {% endif %}

    service.running:
        - enable: True
        - watch:
              - file: selenium-server
              - file: selenium
        - require:
              - openjdk-jre
              - file: selenium-server
              - file: selenium
              - service: xvfb
