smoke.sh-repository:
    git.latest:
        {% if pillar.elife.projects_builder.key %}
        - name: git@github.com:asm89/smoke.sh
        - identity: {{ pillar.elife.projects_builder.key }}
        {% else %}
        - name: https://github.com/asm89/smoke.sh
        {% endif %}
        # updated to 2016-11-30
        - rev: 34ba26aa28279dceaacd16e2b38f51cda6398853
        - branch: master
        - target: /opt/smoke.sh
        - force_fetch: True
        - force_checkout: True
        - force_reset: True

# ensure something is always able to run even if a project has no smoke-tests.sh script
smoke-tests-wrapper-script:
    file.managed:
        - name: /usr/local/bin/smoke-tests
        - source: salt://elife/config/usr-local-bin-smoke-tests
        - mode: 555
