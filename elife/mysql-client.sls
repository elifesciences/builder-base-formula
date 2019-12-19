# `salt.states.mysql_*` require the `python3-mysqldb` library to be installed

mysql-package-list:
    pkg.installed:
        - pkgs:
            - mysql-client
            - python-mysqldb # py2, Salt 2017.7.x
            - python3-mysqldb # py3, Salt 2018.3+
