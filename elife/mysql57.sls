{% set on_rds = salt['elife.cfg']('cfn.outputs.RDSHost') %}
mysql-ppa:
    cmd.run:
        - name: apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5 
        - unless:
            - apt-key list | grep 5072E1F5

    pkgrepo.managed:
        - humanname: Python 2.7 Updates
        - name: deb http://repo.mysql.com/apt/ubuntu/ trusty mysql-5.7
        - file: /etc/apt/sources.list.d/mysql.list
        - dist: trusty
        - require:
            - cmd: mysql-ppa
        - unless:
            - test -e /etc/apt/sources.list.d/mysql.list

{% if not on_rds %}
# have to apply https://github.com/saltstack/salt/issues/9736#issuecomment-176351724
# or the apt-get install can get stuck on the first execution
# assumption is the package does not overwrite this
mysql-custom-init-script:
    file.managed:
        - name: /etc/init.d/mysql
        - source: salt://elife/config/etc-init.d-mysql
        - mode: 755
{% endif %}

mysql-clients:
    pkg.installed:
        - pkgs:
            - mysql-client
            - python-mysqldb
        - refresh: True
        - require:
            - mysql-ppa
    
{% if not on_rds %}
mysql-server:
    pkg.installed:
        - pkgs:
            - mysql-server: 5.7.18-1ubuntu14.04
        # not necessary, done in mysql-clients
        # - refresh: True
        - require:
            - mysql-ppa
            - mysql-clients
            - mysql-custom-init-script

    file.managed:
        - name: /etc/mysql/my.cnf
        - source: salt://elife/config/etc-mysql5.7-my.cnf
        - require:
            - pkg: mysql-server

    service.running:
        - name: mysql 
        - require:
            - pkg: mysql-server
            - file: mysql-server
        - reload: True
{% endif %}

mysql-ready:
    cmd.run:
        - name: echo "MySQL is ready"
        # look also at `require_in:` of other states in this file
        - require:
            - mysql-clients
            {% if not on_rds %}
            - mysql-server
            {% endif %}

{% if not on_rds %}
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
{% endif %}

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

