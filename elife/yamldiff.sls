yamldiff:
    git.latest:
        - name: https://github.com/MattKetmo/yamldiff
        - rev: v1.0.0
        - target: /opt/yamldiff

    file.directory:
        - name: /opt/yamldiff
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - git: yamldiff

    cmd.run:
        - name: composer install
        - user: {{ pillar.elife.deploy_user.username }}
        - cwd: /opt/yamldiff
        - require:
            - composer
            - file: yamldiff

yamldiff-bin:
    file.symlink:
        - name: /usr/local/bin/yamldiff
        - target: /opt/yamldiff/bin/yamldiff
        - require:
            - yamldiff
