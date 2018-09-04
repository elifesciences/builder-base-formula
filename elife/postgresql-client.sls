{% set oscodename = salt['grains.get']('oscodename') %}

# http://www.postgresql.org/download/linux/ubuntu/
postgresql-deb:
    pkgrepo.managed:
        # http://www.postgresql.org/download/linux/ubuntu/
        - humanname: Official Postgresql Ubuntu LTS
        - name: deb http://apt.postgresql.org/pub/repos/apt/ {{ oscodename }}-pgdg main
        - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc

postgresql-client:
    pkg.installed:
        - pkgs:
            - postgresql-client-9.4
        - refresh: True
