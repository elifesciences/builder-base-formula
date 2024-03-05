kubernetes-packages-repo:
    cmd.run:
        - name: |
            curl --fail --silent --show-error --location "https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key" | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
        - creates: /usr/share/keyrings/kubernetes-apt-keyring.gpg

    pkgrepo.managed:
        - humanname: Kubernetes tooling
        - name: deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /
        - file: /etc/apt/sources.list.d/kubernetes.list
        - clean_file: True # lsh@2024-03-05: ensure old PPA is replaced rather than appended to.
        - refresh: True
        - require:
            - cmd: kubernetes-packages-repo

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
