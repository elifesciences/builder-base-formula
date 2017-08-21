nodejs:
    pkgrepo.managed:
        - name: deb http://deb.nodesource.com/node_7.x trusty main
        - key_url: http://deb.nodesource.com/gpgkey/nodesource.gpg.key
        # we get SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure"
        # retry after upgrading Python to latest 2.7.*
        #- name: deb https://deb.nodesource.com/node_7.x trusty main
        #- key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/nodesource.list

    pkg.installed:
        - name: nodejs
        - require:
            - pkgrepo: nodejs
