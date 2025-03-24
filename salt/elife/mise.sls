mise-gpg-present:
    cmd.run:
        - name: |
            curl -1sLf 'https://mise.jdx.dev/gpg-key.pub' | sudo gpg --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg
        - unless:
            - test -f /etc/apt/keyrings/mise-archive-keyring.gpg
mise-repo:
    pkgrepo.managed:
       - name: deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg] https://mise.jdx.dev/deb stable main
       - require:
            - mise-gpg-present
       - refresh_db: true

mise-pkg:
    pkg.installed:
        - name: mise
        - refresh: true # apt-get update prior to installation
        - require:
            - mise-repo
