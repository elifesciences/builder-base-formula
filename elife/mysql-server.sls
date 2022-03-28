{% set osrelease = salt['grains.get']('osrelease') %}
{% set oscodename = salt['grains.get']('oscodename') %}

# lsh@2022-02-21: shouldn't this happen during salt bootstrap?
# `salt.states.mysql_*` require the `python3-mysqldb` library to be installed

# 5.7 in 18.04 
# 8.0 in 20.04

mysql-server:
    pkg.installed:
        - pkgs:
            - mysql-server
            - python3-mysqldb

    file.managed:
        {% if osrelease == '18.04' %}
        - name: /etc/mysql/my.cnf
        - source: salt://elife/config/etc-mysql-my.cnf.{{ oscodename }}
        {% else %}
        # lsh@2022-02-21: switching to preserving my.cnf in 20.04 and freezing mysql.cnf instead
        - name: /etc/mysql/mysql.cnf
        - source: salt://elife/config/etc-mysql-mysql.cnf.{{ oscodename }}
        {% endif %}
        - require:
            - pkg: mysql-server

    service.running:
        - name: mysql 
        - require:
            - pkg: mysql-server
        - watch:
            - file: mysql-server

{% set root = pillar.elife.db_root %}

{% if osrelease == "18.04" %}

# the 'root' db user that has access to *everything*
# untested with RDS
mysql-root-user:
    mysql_user.present:
        - name: {{ root.username }}
        - password: {{ root.password }}
        {% if pillar.elife.env == 'dev' %}
        # allow the root user to connect from outside the virtual machine.
        # '%' is access from ANY host. only use in dev env.
        - host: "%"
        {% else %}
        - host: localhost
        {% endif %}
        - require:
            - mysql-server

    mysql_grants.present:
        - user: {{ root.username }}
        - connection_pass: {{ root.password }}
        - grant: all privileges
        - database: "*.*"
        - require:
            - mysql_user: mysql-root-user

{% if pillar.elife.env == 'dev' and osrelease == "18.04" %}
mysql-root-user-dev-perms:
    mysql_grants.present:
        - user: {{ root.username }}
        - grant: all privileges
        - database: "*.*"
        - connection_pass: {{ root.password }}
        - host: "%" # important! host+database+user constitute another root user
        - require:
            - mysql_user: mysql-root-user
        - require_in:
            - cmd: mysql-ready
{% endif %}


{% else %}

# lsh@2022-03-28: salt seems to choke in mysql 8+ when multiple root users with different 'host' values exist.
# I think. It's confusing. Disabling this other root user in 20.04 temporarily.

{% set database = "*.*" %}
{% set host = "localhost" if pillar.elife.env != "dev" else "%" %}
{% set grants = "all privileges" %}

#mysql-root-user:
#    cmd.script:
#        - name: salt://elife/scripts/mysql-auth.sh
#        - template: jinja
#        - defaults:
#            user: "{{ root.username }}"
#            pass: "{{ root.password }}"
#            host: "{{ host }}"
#            db: "{{ database }}"
#            grants: "{{ grants }}"
#        - require:
#            - mysql-server

{% endif %}

mysql-ready:
    cmd.run:
        - name: echo "MySQL is ready"
        - require:
            - mysql-server
            {% if osrelease == "18.04" %}
            - mysql-root-user
            {% endif %}

