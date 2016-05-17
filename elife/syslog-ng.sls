# configures syslog-ng for minions

syslog-ng-ppa:
    pkgrepo.managed:
        - humanname: syslog-ng most recent stable
        - name: deb http://packages.madhouse-project.org/ubuntu {{ grains['oscodename'] }} syslog-ng syslog-ng-incubator-3.5
        - file: /etc/apt/sources.list.d/syslog-ng.list
        - key_url: http://packages.madhouse-project.org/debian/archive-key.txt

syslog-ng:
    pkg.installed:
        - pkgs:
            - syslog-ng
            - syslog-ng-core
        - require:
            - pkgrepo: syslog-ng-ppa
    
    file.managed:
        - name: /etc/syslog-ng/syslog-ng.conf
        - source: salt://elife/config/etc-syslog-ng-syslog-ng.conf 
        - template: jinja
        - require:
            - pkg: syslog-ng

    service.running:
        - enable: True
        - reload: True
        - require:
            - pkg: syslog-ng
            - file: syslog-ng
        - watch:
            - file: syslog-ng
