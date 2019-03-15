{% set distro = salt['grains.get']('oscodename') %}
nodejs6:
    pkgrepo.managed:
        - name: deb http://deb.nodesource.com/node_6.x {{ distro }} main
        - key_url: http://deb.nodesource.com/gpgkey/nodesource.gpg.key
        # we get SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure"
        # retry after upgrading Python to latest 2.7.*
        #- name: deb https://deb.nodesource.com/node_6.x {{ distro }} main
        #- key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
        - file: /etc/apt/sources.list.d/nodesource.list

    pkg.latest:
        - name: nodejs
        - require:
            - pkgrepo: nodejs6

# 14.04 and 16.04 both come with npm, 18.04 (bionic) does not
{% if distro not in ["trusty", "xenial"] %}
nodejs6-npm:
    # ideal, but 'npm' is apparently a 'virtual package' and salt says it's consituent packages are all installed,
    # when they're not. this is probably the reason virtual package support is being removed in later salt versions
    #pkg.installed:
    #    - name: npm
    #    - require:
    #        - nodejs6
    
    cmd.run:
        - name: apt-get install npm -y --no-install-recommends
        - require:
            - nodejs6

{% endif %}
