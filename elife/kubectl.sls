{% set oscodename = salt['grains.get']('oscodename') %}

kubernetes-packages-repo:
    cmd.run:
        - name: curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
        - unless:
            - apt-key list | grep BA07F4FB

    pkgrepo.managed:
        - humanname: Kubernetes tooling
        - name: deb https://apt.kubernetes.io/ kubernetes-{{ oscodename }} main
        - file: /etc/apt/sources.list.d/kubernetes.list
        - require:
            - cmd: kubernetes-packages-repo
        - unless:
            - test -e /etc/apt/sources.list.d/kubernetes.list

kubectl-package:
    pkg.installed:
        - name: kubectl
        - require:
            - kubernetes-packages-repo
