# `salt.states.mysql_*` require the `python3-mysqldb` library to be installed

mysql-package-list:
    pkg.installed:
        - pkgs:
            - mysql-client
            - python-mysqldb # py2, Salt 2017.7.x
            - python3-mysqldb # py3, Salt 2018.3+

    # on Ubuntu 16.04, in Salt 2018.3, using Python3, there is a problem passing a 
    # bytestring as an argument to a function that expects a regular string.
    # this patch decodes any bytestring arguments into a regular string
    file.patch:
        - name: /usr/lib/python3/dist-packages/MySQLdb/cursors.py
        - source: salt://elife/config/usr-lib-python3-dist-packages-MySQLdb-cursors.py.patch
        # md5 of original file: aca2fb480a76e30f65601018916e86bd
        # md5 of patched file:
        - hash: 15d883d28d4548374522fad16eed560e
        - require:
            # this file is placed here by the above state
            - pkg: mysql-package-list
