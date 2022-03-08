# base nodejs installation
# 18.04 has nodejs 6 and npm 3.10.10
# 20.04 has nodejs 10 and optional npm 6.14.4. npm pulls in python2.7.
# ppa has nodejs 16 (current LTS) and npm 8.3.1
# - see: https://github.com/nodesource/distributions/blob/master/README.md

nodejs:
    pkgrepo.managed:
        - name: deb  https://deb.nodesource.com/node_16.x {{ salt['grains.get']('oscodename') }} main
        - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/nodesource.list

    pkg.installed:
        - name: nodejs
        - require:
            - pkgrepo: nodejs
