{% set distro = salt['grains.get']('oscodename') %}
nodejs6:
    pkgrepo.managed:
        - name: deb http://deb.nodesource.com/node_6.x {{ distro }} main
        - key_url: http://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/nodesource.list

    pkg.installed:
        - name: nodejs
        - version: '6.*' # latest 6.x version, differs by OS release
        - require:
            - pkgrepo: nodejs6
