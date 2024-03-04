{% set smoke_sh_version = '34ba26aa28279dceaacd16e2b38f51cda6398853' %}
{% set smoke_sh_hash = '39a6913a5a6808ad62a84c994b86ff07' %}

smoke.sh-library:
    file.managed:
        - name: /opt/smoke.sh/smoke.sh
        - source: https://raw.githubusercontent.com/asm89/smoke.sh/{{ smoke_sh_version }}/smoke.sh
        - source_hash: md5={{ smoke_sh_hash }}
        - makedirs: True
        - user: root
        - group: root
        - mode: 755

# ensure something is always able to run even if a project has no smoke-tests.sh script
smoke-tests-wrapper-script:
    file.managed:
        - name: /usr/local/bin/smoke-tests
        - source: salt://elife/config/usr-local-bin-smoke-tests
        - mode: 555
