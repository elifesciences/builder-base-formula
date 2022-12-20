# stops any dockerised postgresql container that was brought up by
# postgresql-container.sls and cleans up afterwards.

# stop dockerised postgresql if docker-file present
docker-compose-postgres-down:
    cmd.run:
        - name: /usr/local/bin/docker-compose --file docker-compose.yml down
        - cwd: /home/{{ pillar.elife.deploy_user.username }}/postgres
        # ensure docker-postgresql is stopped before bringing native-postgresql up
        - require_in:
            - service: postgresql
        - onlyif:
            - test -e /home/{{ pillar.elife.deploy_user.username }}/postgres/docker-compose.yml

docker-compose-postgres:
    file.absent:
        - name: /home/{{ pillar.elife.deploy_user.username }}/postgres
