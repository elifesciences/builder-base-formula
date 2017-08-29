# newrelic 'servers' (newrelic.sls) is now deprecated in favour of 
# 'infrastructure' (newrelic-infrastructure.sls)

# this state file now purges the nrsysmond service and will eventually be removed

newrelic-repository:
    #file.managed:
    #    - name: /etc/apt/sources.list.d/newrelic.list
    #    - contents: |
    #        deb http://apt.newrelic.com/debian/ newrelic non-free
    file.absent:
        - name: /etc/apt/sources.list.d/newrelic.list

newrelic-repository-key:
    cmd.run:
        #- name: wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
        - name: apt-key del 548C16BF
        #- unless:
        - onlyif:
            - apt-key list | grep 548C16BF


# this agent monitors CPU, RAM, IO, load...
newrelic-system-daemon-package:
    #pkg.installed:
    #    - name: newrelic-sysmond
    #    - refresh: True
    #    - require:
    #        - newrelic-repository
    #        - newrelic-repository-key
    pkg.purged:
        - name: newrelic-sysmond


#newrelic-system-daemon-license:
#    cmd.run:
#        - name: nrsysmond-config --set license_key={{ pillar.elife.newrelic.license }}
#        - require:
#            - newrelic-system-daemon-package
#        - unless:
#            - grep license_key={{ pillar.elife.newrelic.license }} /etc/newrelic/nrsysmond.cfg

newrelic-system-daemon-license:
    file.absent:
        - name: /etc/newrelic/nrsysmond.cfg

{% set newrelic_hostname = salt['elife.cfg']('project.nodename', 'project.stackname', 'cfn.stack_id', 'Unknown server') %}
#newrelic-system-daemon-hostname:
#    file.replace:
#        - name: /etc/newrelic/nrsysmond.cfg
#        - pattern: "^#?hostname=.*$"
#        - repl: "hostname={{ newrelic_hostname }}"
#        - require:
#            - newrelic-system-daemon-package

{% set newrelic_labels = salt['elife.cfg']('project.project_name', 'Unknown project') %}
{% set newrelic_environment = salt['elife.cfg']('project.instance_id', 'Unknown environment') %}
#newrelic-system-daemon-labels:
#    file.replace:
#        - name: /etc/newrelic/nrsysmond.cfg
#        - pattern: "^#?labels=.*$"
#        - repl: "labels=project:{{ newrelic_labels }},environment={{ newrelic_environment }}"
#        - require: 
#            - newrelic-system-daemon-package
