kubeseal-install:
    archive.extracted:
        - name: /usr/bin
        - source: https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.17.5/kubeseal-0.17.5-linux-amd64.tar.gz
        - user: root
        - group: {{ pillar.elife.deploy_user.username }}
        - source_hash: 7a832db451c09a8bb2c49930b9248c23ddf151f30ff579615e4996317dac9d61
        - if_missing: /usr/bin/kubeseal
        - enforce_toplevel: false
