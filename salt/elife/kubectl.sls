kubernetes-packages-repo:
    # lsh@2023-02-27: disabled. 
    # unpredictable http 500 responses to requests for this key today.
    # also, 'apt-key' is now deprecated and is last available in 22.04.
    # shifting key into config.
    #cmd.run:
    #    - name: curl --silent https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    #    - unless:
    #        - apt-key list | grep BA07F4FB

    pkgrepo.managed:
        - humanname: Kubernetes tooling
        # lsh@2020-04: there is no kubernetes-bionic, only xenial. no explanation found.
        - name: deb https://apt.kubernetes.io/ kubernetes-xenial main
        - key_url: salt://elife/config/packages.cloud.google.com--apt--doc--apt-key.gpg
        - file: /etc/apt/sources.list.d/kubernetes.list
        #- require:
        #    - cmd: kubernetes-packages-repo
        - unless:
            - test -e /etc/apt/sources.list.d/kubernetes.list

kubectl-package:
    pkg.installed:
        - name: kubectl
        - require:
            - kubernetes-packages-repo

{% for cluster_name, cluster_configuration in pillar.elife.eks.clusters.items() %}
aws-eks-update-kube-config-{{ cluster_name }}:
    cmd.run:
        - name: aws eks update-kubeconfig --name {{ cluster_name }} --role-arn {{ cluster_configuration['role'] }}
        - env:
            - AWS_DEFAULT_REGION: {{ cluster_configuration['region'] }}
        - runas: {{ pillar.elife.kubectl.username }}
        - require:
            - kubectl-package
{% endfor %}
