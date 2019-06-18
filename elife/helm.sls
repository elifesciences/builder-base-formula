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
        - name: helm init --client-only
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - helm

helm-s3-plugin:
    cmd.run:
        - name: helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.7.0
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - helm-init

helm-s3-charts-repository:
    cmd.run:
        - name: helm repo add alfred s3://prod-elife-alfred/helm-charts
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - helm-s3-plugin
