{% set helm_version = '2.11.0' %}
{% set helm_hash = '0093f1f1c4590d7c4655883909948082' %}
{% set helm_archive = 'helm-v' + helm_version + '-linux-amd64.tar.gz' %}
helm:
    file.managed:
        - name: /root/{{ helm_archive }}
        - source: https://storage.googleapis.com/kubernetes-helm/{{ helm_archive }}
        - source_hash: md5={{ helm_hash }}

    cmd.run:
        - name: tar -xvzf {{ helm_archive }} && mv linux-amd64/helm linux-amd64/tiller /usr/local/bin/
        - cwd: /root

helm-init:
    cmd.run:
        - name: helm init --client-only --stable-repo-url=https://charts.helm.sh/stable
        - runas: {{ pillar.elife.helm.username }}
        - require:
            - helm

make-dependency:
    pkg.installed:
        - name: make

helm-s3-plugin:
    cmd.run:
        - name: helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.7.0
        - runas: {{ pillar.elife.helm.username }}
        - unless:
            -  helm plugin list | grep '^s3 '
        - require:
            - make-dependency
            - helm-init

{% if salt['elife.only_on_aws']() %}
helm-s3-charts-repository:
    cmd.run:
        - name: helm repo add alfred s3://prod-elife-alfred/helm-charts
        - runas: {{ pillar.elife.helm.username }}
        - require:
            - helm-s3-plugin
{% endif %}
