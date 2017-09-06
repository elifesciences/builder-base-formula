{% set root = pillar.elife.db_root %}
{% set oscodename = salt['grains.get']('oscodename') %}

mysql-server:
    pkg:
        - installed

    file.managed:
        - name: /etc/mysql/my.cnf
        - source: salt://elife/config/etc-mysql-my.cnf.{{ oscodename }}
        - require:
            - pkg: mysql-server

    service.running:
        - name: mysql 
        - require:
            - pkg: mysql-server
        - watch:
            - file: mysql-server


# the 'root' db user that has access to *everything*
# untested with RDS, doesn't work as intended with PostgreSQL.
mysql-root-user:
    mysql_user.present:
        - name: {{ root.username }}
        - password: {{ root.password }}
        - host: localhost
        - require:
            - mysql-server

    mysql_grants.present:
        - user: {{ root.username }}
        - connection_pass: {{ root.password }}
        - grant: all privileges
        - database: "*.*"
        - require:
            - mysql_user: mysql-root-user

{% if pillar.elife.env == 'dev' %}
# within a dev environment the root user can connect from outside the machine
mysql-root-user-dev-perms:
    mysql_user.present:
        - name: {{ root.username }}
        - password: {{ root.password }} 
        - connection_pass: {{ root.password }}
        - host: "%" # access from ANYWHERE. not to be used in production
        - require:
            - mysql-server

    mysql_grants.present:
        - user: {{ root.username }}
        - grant: all privileges
        - database: "*.*"
        - host: "%" # important! this+database+user constitute another root user
        - require:
            - mysql_user: mysql-root-user-dev-perms
        - require_in:
            - mysql-ready
{% endif %}


mysql-ready:
    cmd.run:
        - name: echo "MySQL is ready"
        - require:
            - mysql-server
            - mysql-root-user

