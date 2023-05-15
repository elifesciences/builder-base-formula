# docker-databases.sls
# allows containerised apps access to the installation of postgresql on the *host* system.
#
# allowing access using a specific IP is tricky as psql must be restarted after docker brings up it's interface.
# instead the wildcard '*' is used, allowing connections from *anywhere* to psql on port 5432.
# this *doesn't* require psql to be restarted but is less secure.
# use pg_hba.conf to further control hosts, users and authentication.

docker-network-databases:
    cmd.run:
        - name: docker network create databases
        - unless:
            - docker network inspect databases
        - require:
            - docker-ready

postgresql-12-docker-config:
    file.managed:
        - name: /etc/postgresql/12/main/conf.d/docker.conf
        - source: salt://elife/config/etc-postgresql-conf.d-docker.conf
        - require:
            - pkg: postgresql
        - require_in:
            - service: postgresql
        - onlyif:
            - test -d /etc/postgresql/12
