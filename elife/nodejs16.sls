# base nodejs installation
# 18.04 has nodejs 6 and npm 3.10.10
# 20.04 has nodejs 10 and optional npm 6.14.4. npm pulls in python2.7.
# ppa has nodejs 16 (current LTS) and npm 8.3.1
# - see: https://github.com/nodesource/distributions/blob/master/README.md

nodejs6 ppa absent:
    file.absent:
        - name: /etc/apt/sources.list.d/nodesource.list

nodejs16:
    pkgrepo.managed:
        - name: deb  https://deb.nodesource.com/node_16.x {{ salt['grains.get']('oscodename') }} main
        - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/node16source.list
        - require:
            - nodejs6 ppa absent

    pkg.latest:
        - name: nodejs
        - require:
            - pkgrepo: nodejs
