# `salt.states.mysql_*` require the `python3-mysqldb` library to be installed

mysql-package-list:
    pkg.installed:
        - pkgs:
            - mysql-client
            - python3-mysqldb
