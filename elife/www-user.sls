#
# creates the 'www-data' user,
# and adds the 'elife' user to it's group.
#

# installing apache/nginx will also create this user, 
# however caddy uses a user+group called 'caddy'.
# too much relies on a www-data user for caddy to be special.

# when 'elife' user is in 'www-data' group,
# 'elife' can read and write 'www-data' owned files and directories.
# this is important when CLI cmds are run by a human as 'elife',
# and the webserver is running and writing files as 'www-data'.

webserver-user-group:
    group.present:
        - name: {{ pillar.elife.webserver.username }} # www-data
        - addusers:
            - {{ pillar.elife.deploy_user.username }}

    user.present:
        - name: {{ pillar.elife.webserver.username }}
        - home: /var/www
        - createhome: true
        - groups:
            - www-data
        - require:
            - group: webserver-user-group

# unnecessary on new machines as "webserver-user-group.user.home = /var/www" *should* create a correct /var/www
# caddy depends on /var/www to write the OCSP staple file and treats it as it's XDG_* home.
webserver-user-can-write-var-www:
    file.directory:
        - name: /var/www
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - require:
            - webserver-user-group
        - listen_in:
            - service: caddy-server-service

