docker-network-databases:
    cmd.run:
        - name: docker network create databases
        - unless:
            - docker network inspect databases
        - require:
            - docker-ready

# lsh@2022-12-20: allow docker containers to access host psql.
# using a specific IP is tricky as it relies on psql being restarted after docker brings up it's interface.
# instead the wildcard '*' is used, allowing connections from *anywhere* to psql on port 5432.
# use pg_hba.conf to further control hosts, users and authentication.
postgresql-11-docker-config:
    file.managed:
        - name: /etc/postgresql/11/main/conf.d/docker.conf
        - source: salt://elife/config/etc-postgresql-conf.d-docker.conf
        - require:
            - pkg: postgresql
        - require_in:
            - cmd: postgresql-ready
        - onlyif:
            - test -d /etc/postgresql/11

postgresql-12-docker-config:
    file.managed:
        - name: /etc/postgresql/12/main/conf.d/docker.conf
        - source: salt://elife/config/etc-postgresql-conf.d-docker.conf
        - require:
            - pkg: postgresql
        - require_in:
            - cmd: postgresql-ready
        - onlyif:
            - test -d /etc/postgresql/12
