nodejs:
    pkgrepo.managed:
        - name: deb https://deb.nodesource.com/node_6.x trusty main
        - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/nodesource.list

    pkg.installed:
        - name: nodejs
        - require:
            - pkgrepo: nodejs
