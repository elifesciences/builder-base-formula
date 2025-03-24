mise-gpg-present:
    file.directory:
        - name: /etc/apt/keyrings
        - user: root
        - group: root
        - mode: 755
    cmd.run:
        - name: |
            curl -1sLf 'https://mise.jdx.dev/gpg-key.pub' | sudo gpg --dearmor -o /etc/apt/keyrings/mise-archive-keyring.gpg
        - unless:
            - test -f /etc/apt/keyrings/mise-archive-keyring.gpg
        - require:
            - file: mise-gpg-present
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
