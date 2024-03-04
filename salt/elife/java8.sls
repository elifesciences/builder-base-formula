# both 16.04 and 18.04 have a "openjdk-8-jre-headless" package

# native openjdk 8 packages

java8:
    pkg.installed:
        - pkgs: 
            - openjdk-8-jre-headless
        
    cmd.run:
        - name: echo "java8 installed"
        - require:
            - pkg: java8
