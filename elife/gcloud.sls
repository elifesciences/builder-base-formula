google-cloud-packages-repo:
    cmd.run:
        - name: curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        - unless:
            - apt-key list | grep BA07F4FB

    pkgrepo.managed:
        - humanname: Kubernetes tooling
        - name: deb http://apt.kubernetes.io/ cloud-sdk-xenial main
        - file: /etc/apt/sources.list.d/google-cloud.list
        - require:
            - cmd: google-cloud-packages-repo
        - unless:
            - test -e /etc/apt/sources.list.d/google-cloud.list

gcloud-package:
    pkg.installed:
        - name: google-cloud-sdk
        - require:
            - google-cloud-packages-repo

{% for account, configuration in pillar.elife.gcloud.accounts.items() %}
{% set key_file = pillar.elife.gcloud.directory + '/' + account + '/gcp.json' %}
gcloud-login-{{ account }}:
    # provision private key somewhere in home folder (pillar-configurable)
    file.managed: 
        - name: {{ key_file }}
        - source: {{ configuration['credentials'] }}
        - user: {{ pillar.elife.gcloud.username }}
        - group: {{ pillar.elife.gcloud.username }}
        - makedirs: True
        - require:
            - gcloud-package

    # authenticate
    cmd.run:
        - name: gcloud auth activate-service-account --key-file={{ key_file }}
        - require:
            - file: gcloud-login-{{ account }}

gcloud-kubectl-{{ account }}:
    # take out credentials 
    cmd.run:
        - name: gcloud container clusters get-credentials {{ configuration['cluster'] }} --project {{ configuration['project'] }} --zone {{ configuration['zone'] }}
        - require:
            - gcloud-login-{{ account }}
{% endfor %}
