
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
            systemctl enable {{ process }}@{0..{{ num_processes - 1}}} # enable just the range we're after. implicit reload
            {% endif %}
            systemctl start {{ process }}-controller.target
        - require:
            - file: {{ opts["service_template"] }} # name of state that manages the systemd service template file

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

{% endfor %}
