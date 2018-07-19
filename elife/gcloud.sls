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
