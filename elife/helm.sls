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
