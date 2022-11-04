# removes the apache2 package that has a bad habit of sneaking in
# through transitive dependencies.

stop-apache:
    service.dead:
        - name: apache2
        - enable: false

purge-apache:
    pkg.purged:
        - pkgs:
            - apache2
            - apache2-bin

