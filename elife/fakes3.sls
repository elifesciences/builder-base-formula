ruby:
    pkg.installed

fakes3-installation:
    cmd.run:
        - name: gem install fakes3
        - require:
            - ruby

fakes3-directory:
    file.directory:
        - name: /home/{{ pillar.elife.deploy_user.username }}/fakes3
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}

fakes3-upstart:
    file.managed:
        - name: /etc/init/fakes3.conf
        - source: salt://elife/config/etc-init-fakes3.conf
        - mode: 644
        - template: jinja

fakes3-systemd:
    file.managed:
        - name: /lib/systemd/system/fakes3.service
        - source: salt://elife/config/lib-systemd-system-fakes3.service
        - template: jinja

fakes3:
    service.running:
        - name: fakes3
        - require:
            - fakes3-installation
            - fakes3-directory
            - fakes3-upstart
            - fakes3-systemd
