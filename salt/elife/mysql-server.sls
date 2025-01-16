# lsh@2022-02-21: shouldn't this happen during salt bootstrap?
# `salt.states.mysql_*` require the `python3-mysqldb` library to be installed

# MySQL 8.0 in 20.04
{% set oscodename = salt['grains.get']('oscodename') %}

mysql-server:
    pkg.installed:
        - pkgs:
            - mysql-server
            - python3-mysqldb

    file.managed:
        - name: /etc/mysql/mysql.cnf
        - source: salt://elife/config/etc-mysql-mysql.cnf.{{ oscodename }}
        - require:
            - pkg: mysql-server

    service.running:
        - name: mysql
        - require:
            - pkg: mysql-server
        - watch:
            - file: mysql-server

{% set root = pillar.elife.db_root %}

# lsh@2022-03-28: work around for mysql user grants issues with mysql8+ in 20.04.

{% set database = "*.*" %}
{% set host = "localhost" if pillar.elife.env != "dev" else "%" %}
{% set grants = "all privileges" %}

mysql-root-user:
    cmd.script:
        - name: salt://elife/scripts/mysql-auth.sh
        - template: jinja
        - defaults:
            user: "{{ root.username }}"
            pass: "{{ root.password }}"
            host: "{{ host }}"
            db: "{{ database }}"
            grants: "{{ grants }}"
        - require:
            - mysql-server


mysql-ready:
    cmd.run:
        - name: echo "MySQL is ready"
        - require:
            - mysql-server
            - mysql-root-user
