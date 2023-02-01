
# systemd managed group processes

# 1. N number of the given process are running
# 2. the pool of processes can be grown or shrunk
# 3. broken processes fail highstate as they ordinarily would

{% for process, opts in pillar.elife.multiservice.services.items() %}
    {% set num_processes = opts["num_processes"] %}

# ensure the target state controller is available and running
{{ process }}-controller.target:
    file.managed:
        - name: /lib/systemd/system/{{ process }}-controller.target
        - source: salt://elife/templates/process-controller.target

# ensure precisely N processes are running
{{ process }}-set-restart:
    cmd.run:
        - name: |
            set -e
            systemctl stop {{ process }}@{0..99} # stop any running instances of this service.
            #systemctl stop {{ process }}-controller.target # would also work, but wouldn't catch services outside controller group
            systemctl disable {{ process }}@ # disable *everything*. implicit reload
            {% if num_processes > 0 %}
            # lsh@2023-02-01: something caused, or is causing, systemd to create an escaped version of the process.
            # switched to a for-loop because I don't know what is causing it.
            #systemctl enable {{ process }}@{0..{{ num_processes - 1}}} # enable just the range we're after. implicit reload
            {% for i in range(0, num_processes) %}
            systemctl enable {{ process }}@{{ i }}
            {% endfor %}
            {% endif %}
        - require:
            - {{ process }}-controller.target
            - file: {{ opts["service_template"] }} # name of state that manages the systemd service template file

    {% if num_processes > 0 %}
    service.running:
        - name: {{ process }}-controller.target
        - enable: True
        # results in a recursive requisite
        #- require:
        #    - cmd: {{ process }}-set-restart
    {% endif %}

# 3. broken processes fail highstate as they ordinarily would
{% for i in range(0, num_processes) %}
{{ process }}@{{ i }}:
    service.running:
        {% if "init_delay" in opts %}
        - init_delay: {{ opts["init_delay"] }}
        {% endif %}
        - require:
            - {{ process }}-set-restart
{% endfor %}

# lsh@2023-02-01: a weird looking process was discovered and tracked to here multiservice.sls
# something in the 'systemctl enable process@{0..N}' caused, or is causing, systemd to create an escaped version of the process.
# this stops and disables those processes, if they exist.
# - https://github.com/elifesciences/issues/issues/7980
stop-disable-bogus-process--{{ process }}:
    service.dead:
        - name: "{{ process }}@\x7b0..{{ num_processes - 1 }}\x7d"
        - enable: false

{% endfor %}
