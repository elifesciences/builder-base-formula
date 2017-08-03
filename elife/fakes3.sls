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

fakes3:
    file.managed:
        - name: /etc/init/fakes3.conf
        - source: salt://elife/config/etc-init-fakes3.conf
        - mode: 644
        - template: jinja
        - require:
            - fakes3-installation
            - fakes3-directory
    
    service.running:
        - name: fakes3
        - require:
            - file: fakes3
