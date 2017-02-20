smoke.sh-repository:
    git.latest:
        - name: git@github.com:asm89/smoke.sh
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        # updated to 2016-11-30
        - rev: 34ba26aa28279dceaacd16e2b38f51cda6398853
        - branch: master
        - target: /opt/smoke.sh
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
