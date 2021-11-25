java8:
    pkg.installed:
        - pkgs: 
            - openjdk-8-jre-headless

    # todo: necessary? this seems like an old hook something might rely on
    cmd.run:
        - name: echo "java8 installed"
        - require:
            - pkg: java8
