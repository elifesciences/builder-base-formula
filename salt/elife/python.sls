{% set osrelease = salt['grains.get']('osrelease') %}

# 3.6 in 18.04
# 3.8 in 20.04
python-3:
    pkg.installed:
        - pkgs:
            - python3
            - python3-pip
            - python3-venv

python-dev:
    pkg.installed:
        - pkgs:
            - python3-dev
            - libffi-dev 
            - libssl-dev
        - require:
            - python-3

global-python-requisites:
    cmd.run:
        # lsh@2021-11-29: adds pipenv to globally available python tools.
        # it needs to live outside of the 'update-dependencies.sh' script otherwise it becomes part of the requirements file.
        - name: |
            set -e
            python3 -m pip install pip wheel virtualenv --upgrade --quiet
            python3 -m pip install pipenv==2022.1.8 --quiet

# At 12:00 AM, on day 1 of the month
monthly-pip-cache-purge:
    cron.present:
        - user: root
        - identifier: cache-purge
        - name: pip3 cache purge
        - minute: 0
        - hour: 0
        - daymonth: 1
        - month: '*'
        - require:
            - install-ubr
