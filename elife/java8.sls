# both 16.04 and 18.04 have a "openjdk-8-jre-headless" package

# remove oracle java (if it exists)

oracle-ppa-removal:
    pkgrepo.absent:
        # https://docs.saltstack.com/en/latest/ref/states/all/salt.states.pkgrepo.html#salt.states.pkgrepo.absent
        - ppa: webupd8team/java # no idea if this is correct

oracle-java8-installer-removal:
    pkg.purged:
        - name: oracle-java8-installer
        - require:
            - oracle-ppa-removal


# native openjdk 8 packages

java8:
    pkg.installed:
        - pkgs: 
            - openjdk-8-jre-headless
        - refresh: True # necessary?
        - require:
            - oracle-java8-installer-removal
        
    cmd.run:
        - name: echo "java8 installed"
        - require:
            - pkg: java8
