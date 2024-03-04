# configures syslog-ng for minions

syslog-ng-ppa:

# LSH 2016-09-30: the syslog-ng-incubator package is no longer needed and the 
# native syslog-ng can be used instead. that package provided functionality for
# connecting to Riemann that was used in the defunct `central-monitor` project.
#    pkgrepo.managed:
#        - humanname: syslog-ng most recent stable
#        - name: deb http://packages.madhouse-project.org/ubuntu {{ grains['oscodename'] }} syslog-ng syslog-ng-incubator-3.5
#        - file: /etc/apt/sources.list.d/syslog-ng.list
#        - key_url: http://packages.madhouse-project.org/debian/archive-key.txt

    pkgrepo.absent:
        - name: deb http://packages.madhouse-project.org/ubuntu {{ grains['oscodename'] }} syslog-ng syslog-ng-incubator-3.5

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
