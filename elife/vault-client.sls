# simplified from https://github.com/elifesciences/master-server-formula/blob/27cf38250da0a339cbb591d400b00249ca0bbdec/salt/master-server/vault.sls
{% set vault_version = '0.11.0' %}
{% set vault_hash = 'ca9316e4864a9585f7c6507e38568053' %}
{% set vault_archive = 'vault_' + vault_version + '_linux_amd64.zip' %}
vault-binary:
    file.managed:
        - name: /root/{{ vault_archive }}
        - source: https://releases.hashicorp.com/vault/{{ vault_version }}/{{ vault_archive }}
        - source_hash: md5={{ vault_hash }}

    archive.extracted:
        - name: /opt/vault/
        - source: /root/{{ vault_archive }}
        - enforce_toplevel: False
        - require:
            - file: vault-binary

vault-client:
    file.symlink:
        - name: /usr/local/bin/vault
        - target: /opt/vault/vault
        - require:
            - vault-binary
