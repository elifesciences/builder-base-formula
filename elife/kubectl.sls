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

# allows kubectl to use AWS IAM users/roles
{% set aws_iam_authenticator_hash = 'c7867c698a38acb3e0a2976cb7b3d0f9' %}
{% set aws_iam_authenticator_url = 'https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator' %}
aws-iam-authenticator-binary:
    file.managed:
        - name: /usr/local/bin/aws-iam-authenticator
        - source: {{ aws_iam_authenticator_url }}
        - source_hash: md5={{ aws_iam_authenticator_hash }}
        - mode: 555

# TODO: add `AWS_DEFAULT_REGION=us-east-1 aws eks update-kubeconfig --name kubernetes--demo` configured via pillars

