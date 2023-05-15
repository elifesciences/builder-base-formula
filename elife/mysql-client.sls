{% set osrelease = salt['grains.get']('osrelease') %}

# lsh@2022-02-21: shouldn't this happen during salt bootstrap?
# `salt.states.mysql_*` require the `python3-mysqldb` library to be installed

mysql-package-list:
    pkg.installed:
        - pkgs:
            - mysql-client
            - python3-mysqldb # py3, Salt 2018.3+

