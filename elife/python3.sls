# DEPRECATED. replaced with python.sls for 16.04

# pkgrepo for 3.5+, should already be configured by builder's Salt bootstrap
# officially abandoned, but unofficially being updated
# https://launchpad.net/~fkrull/+archive/ubuntu/deadsnakes/+index?batch=75&direction=backwards&start=75

# installs the latest version of python 3 (3.6)

{% if not salt['grains.get']('osrelease') == "16.04" %}

python-3:
    cmd.run:
        - name: apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5BB92C09DB82666C
        - require:
            - global-python-requisites

    pkgrepo.managed:
        - humanname: Python 2.7 Updates
        - ppa: fkrull/deadsnakes
        - require:
            - cmd: python-3
        - unless:
            - test -e /etc/apt/sources.list.d/fkrull-deadsnakes-trusty.list
            
    pkg.installed:
        - pkgs:
            # nothing uses python 3.4 or 3.6
            # django has/had issues with 3.6 when last tested so we settled on 3.5
            # 3.6 is expected to be available in 18.04 but not as default
            - python3.4
            - python3.4-dev
            - python3.5
            - python3.5-dev
            - python3.6
            - python3.6-dev

            # ubuntu ... ffs. issue exists in 16.04 too
            # https://bugs.launchpad.net/ubuntu/+source/python3.4/+bug/1290847
            - python3.5-venv
{% endif %}
