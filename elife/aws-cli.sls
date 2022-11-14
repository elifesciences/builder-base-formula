
# lsh@2022-10-12: `awscli` was originally installed with pip because the system package got old quickly.
# This was in 12.04 or 14.04. In 20.04 it may be more stable however I've opted to continue using the latest 
# but wrapping it in a script with it's own virtualenv because of library mismatches with openssl:
# - https://github.com/elifesciences/issues/issues/7782

remove-aws-cli:
    cmd.run:
        - name: python3 -m pip uninstall awscli --quiet -y

    pkg.purged:
        - name: awscli

aws-cli:
    file.managed:
        - name: /usr/local/bin/aws
        - source: salt://elife/scripts/aws
        - mode: 775
        - require:
            - remove-aws-cli
