
# systemd managed group processes

# 1. N number of the given process are running
# 2. the pool of processes can be grown or shrunk
# 3. broken processes fail highstate as they ordinarily would

{% set process = "test" %}
{% set num_processes = 0 %}

/opt/{{ process }}.py:
    file.managed:
        - source: salt://elife/scripts/test.py

{{ process }}-template:
    file.managed:
        - name: /lib/systemd/system/{{ process }}@.service
        - source: salt://elife/config/lib-systemd-system-test.service
        - template: jinja
        - context:
            process: {{ process }}
        - require:
            - /opt/{{ process }}.py

#
#
#

# ensure the target state is available and running
{{ process }}-controller.target:
    file.managed:
        - name: /lib/systemd/system/{{ process }}-controller.target
        - source: salt://elife/templates/process-controller.target

    service.running:
        - enable: true
        - require:
            - file: {{ process }}-controller.target

# ensure precisely N processes are enabled. restart controller if N has changed
# enabled processes are started when the controller state changes
{{ process }}-set-enabled:
    cmd.run:
        - name: |
            set -e
            systemctl stop {{ process }}@{0..99} # stop any running instances of this service.
            systemctl disable {{ process }}@ # disable *everything*. implicit reload
            {% if num_processes > 0 %}
            systemctl enable {{ process }}@{0..{{ num_processes - 1}}} # enable just the range we're after. implicit reload
            {% endif %}
        - require:
            - file: {{ process }}-template
        - onlyif:
            # only run command when the expected number of processes (enabled and running) is not equal to the intended 
            # number of processes. 
            # use 'is-enabled' to find enabled units. it conveniently returns 'disabled' if all are disabled, so grep for 'enabled'
            # use 'show' and grep for the pid for running units. it conveniently returns MainPID=0 for enabled-but-not-running units
            - test {{ num_processes }} != $(systemctl is-enabled {{ process }}@{0..99} | grep 'enabled' | wc -l) || \
              test {{ num_processes }} != $(systemctl show {{ process }}@{0..99} | grep '^MainPID=[^0]' | wc -l)
        - watch_in:
            - service: {{ process }}-controller.target

# ensure N processes are running 
{% for i in range(0, num_processes) %}
{{ process }}@{{ i }}:
    service.running:
        - enable: true # redundant, but can't hurt
        - require:
            - {{ process }}-set-enabled
            - {{ process }}-controller.target
{% endfor %}
