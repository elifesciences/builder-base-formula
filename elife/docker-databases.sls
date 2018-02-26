docker-network-databases:
    cmd.run:
        - name: docker network create databases
        - unless:
            - docker network inspect databases
        - require:
            - docker-ready

