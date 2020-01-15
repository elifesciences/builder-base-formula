{% set distro = salt['grains.get']('oscodename') %}
nodejs7:
    pkgrepo.managed:
        - name: deb http://deb.nodesource.com/node_7.x {{ distro }} main
        - key_url: http://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/nodesource.list

    pkg.installed:
        - name: nodejs
        - require:
            - pkgrepo: nodejs7
