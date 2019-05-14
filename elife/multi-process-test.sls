
# test that N processes are brought using a single service state
# each process simply writes it's identifier and the time to the syslog

{% set process = "test" %}
{% set num_processes = 10 %}

/opt/{{ process }}.py:
    file.managed:
        - source: salt://elife/scripts/test.py

{{ process }}:
    file.managed:
        - name: /lib/systemd/system/{{ process }}@.service
        - source: salt://elife/config/lib-systemd-system-test.service
        - template: jinja
        - context:
            process: {{ process }}
        - require:
            - /opt/{{ process }}.py

    # neccessary because salt mangles "service@{x..y}" to "service@\x7bx..y\x7d.service" 
    # systemd will see that as just a single instantiated service
    cmd.run:
        - name: |
            set -e
            systemctl disable {{ process }}@{0..99} # disable all instances (up to 99). implicit reload
            systemctl enable {{ process }}@{0..1} # enable just the range we're after. implicit reload
        - require:
            - file: {{ process }}
        # only run command if there are disabled instances in our range
        # todo: only runs if range grows. if range shrinks to 0..0 from 0..1 then this command won't be triggered
        - onlyif:
            - systemctl is-enabled {{ process }}@{0..1} | grep -q 'disabled'

{{ process }}-controller.target:
    file.managed:
        - name: /lib/systemd/system/{{ process }}-controller.target
        - source: salt://elife/templates/process-controller.target

    service.running:
        - enable: true
        - require:
            - file: {{ process }}-controller.target
            - cmd: {{ process }}
        # restarts target (and all processes that need that target) when processes enabled
        - watch:
            - cmd: {{ process }}
