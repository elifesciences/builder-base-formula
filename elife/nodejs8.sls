{% set distro = salt['grains.get']('oscodename') %}
nodejs8:
    pkgrepo.managed:
        - name: deb http://deb.nodesource.com/node_8.x {{ distro }} main
        - key_url: http://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/nodesource.list

    pkg.installed:
        - name: nodejs
        - version: '8.*'
        - require:
            - pkgrepo: nodejs8
