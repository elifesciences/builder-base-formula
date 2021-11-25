# DEPRECATED: to be removed (eventually) without replacement
python-2.7:
    pkg.installed:
        - pkgs: 
            - python2.7
            - python-pip

# 3.5 in 16.04
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
            - python2.7-dev
            - python3-dev
            - libffi-dev 
            - libssl-dev
        - require:
            - python-2.7
            - python-3

global-python-requisites:
    cmd.run:
        - name: python3 -m pip install pip wheel --upgrade
        - require:
            - python-2.7

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
