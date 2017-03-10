mysql-server-ppa:
    #cmd.run:
    #    - name: apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
    #    - unless:
    #        - apt-key list | grep E5267A6C

    # https://launchpad.net/~ondrej/+archive/ubuntu/mysql-5.7
    #pkgrepo.managed:
    #    - humanname: Ondřej Surý PHP PPA
    #    - ppa: ondrej/mysql-5.7
    #    - require:
    #        - cmd: mysql-server-ppa
    #    - unless:
    #        - test -e /etc/apt/sources.list.d/ondrej-mysql-5_7-trusty.list

    cmd.run:
        - name: apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5 
        - unless:
            - apt-key list | grep 5072E1F5

    # alternative: untested official MySQL repository
    pkgrepo.managed:
        - humanname: Python 2.7 Updates
        - name: deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7
        - file: /etc/apt/sources.list.d/mysql.list
        - dist: trusty
        - require:
            - cmd: mysql-server-ppa
        - unless:
            - test -e /etc/apt/sources.list.d/mysql.list

mysql-server:
    pkg.installed:
        - pkgs:
            - mysql-server
            - mysql-client
            - python-mysqldb
        - refresh: True
        - require:
            - pkgrepo: mysql-server-ppa

    file.managed:
        - name: /etc/mysql/my.cnf
        - source: salt://elife/config/etc-mysql5.7-my.cnf
        - require:
            - pkg: mysql-server

    service.running:
        - name: mysql 
        - require:
            - pkg: mysql-server
        - watch:
            - file: mysql-server

mysql-ready:
    cmd.run:
        - name: echo "MySQL is ready"
        - require:
            - mysql-server
            # look at require_in: of other states in this file

{% set root = pillar.elife.db_root %}

# the 'root' db user that has access to *everything*
mysql-root-user:
    mysql_user.present:
        - name: {{ root.username }}
        - password: {{ root.password }} 
        - host: localhost
        - require:
            - service: mysql-server

    mysql_grants.present:
        - user: {{ root.username }}
        - connection_pass: {{ root.password }}
        - grant: all privileges
        - database: "*.*"
        - require:
            - service: mysql-server
            - mysql_user: mysql-root-user
        - require_in:
            - cmd: mysql-ready

{% if pillar.elife.env == 'dev' %}
# within a dev environment the root user can connect from outside the machine
mysql-root-user-dev-perms:
    mysql_user.present:
        - name: {{ root.username }}
        - password: {{ root.password }} 
        - connection_pass: {{ root.password }}
        - host: "%" # access from ANYWHERE. not to be used in production
        - require:
            - service: mysql-server

    mysql_grants.present:
        - user: {{ root.username }}
        - connection_pass: {{ root.password }}
        - grant: all privileges
        - database: "*.*"
        - host: "%" # important! this+database+user constitute another root user
        - require:
            - service: mysql-server
            - mysql_user: mysql-root-user-dev-perms
        - require_in:
            - cmd: mysql-ready
{% endif %}

