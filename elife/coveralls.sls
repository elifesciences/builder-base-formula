{% for project, token in pillar.elife.coveralls.tokens.items() %}
{% set pname = project|replace("_", "-") %}
coveralls-{{ pname }}:
    file.managed:
        - name: /etc/coveralls/tokens/{{ pname }}
        - contents: {{ token }}
        - makedirs: True
        - mode: 644
{% endfor %}
