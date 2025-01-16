mysql-package-list:
    pkg.installed:
        - pkgs:
            - mysql-client
            # lsh@2023-05-17: disabled. salt+mysql support is now installed during bootstrap.
            # Have also switched from 'MySQLdb' to 'PyMYSQL'. Former is a C extension, latter is pure python and
            # Salt supports both: https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.mysql.html
            #- python3-mysqldb
