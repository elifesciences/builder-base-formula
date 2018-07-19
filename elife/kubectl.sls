kubernetes-pkgrepo:
    cmd.run:
        - name: curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        - unless:
            - apt-key list | grep BA07F4FB

    pkgrepo.managed:
        - humanname: Kubernetes tooling
        - name: deb http://apt.kubernetes.io/ kubernetes-xenial main
        - file: /etc/apt/sources.list.d/kubernetes.list
        - require:
            - cmd: kubernetes-pkgrepo
        - unless:
            - test -e /etc/apt/sources.list.d/kubernetes.list

kubectl-package:
    pkg.installed:
        - name: kubectl
        - require:
            - kubernetes-pkgrepo

{% for filename, source in pillar.elife.kubectl.kubeconfigs.items() %}
kubectl-kubeconfig-{{ filename }}:
    file.managed:
        - name: {{ pillar.elife.kubectl.directory }}/{{ filename }}
        - source: {{ source }}
        - user: {{ pillar.elife.kubectl.username }}
        - group: {{ pillar.elife.kubectl.username }}
        - makedirs: True
        - require:
            - kubectl-package
{% endfor %}
