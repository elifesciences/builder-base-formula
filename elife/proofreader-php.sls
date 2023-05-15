proofreader-php-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/proofreader-php.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ pillar.elife.proofreader_php.version }}
        - branch: master
        - target: /srv/proofreader-php
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - require:
            - composer

    file.directory:
        - name: /srv/proofreader-php
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: proofreader-php-repository

    cmd.run:
        - name: |
            composer --quiet --no-interaction update --no-suggest --classmap-authoritative --no-dev
        - runas: {{ pillar.elife.deploy_user.username }}
        - cwd: /srv/proofreader-php
        - require:
            - file: proofreader-php-repository

srv-bin-folder:
    file.directory:
        - name: /srv/bin
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - deploy-user
            - proofreader-php-repository

srv-bin-folder-on-path:
    file.managed:
        - name: /etc/profile.d/srv-bin.sh
        - contents: export PATH=/srv/bin:$PATH
        - require:
            - srv-bin-folder

proofreader-php:
    file.symlink:
        - name: /srv/bin/proofreader
        - target: /srv/proofreader-php/bin/proofreader
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - proofreader-php-repository
            - srv-bin-folder-on-path
