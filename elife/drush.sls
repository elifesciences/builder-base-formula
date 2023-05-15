{% set user = pillar.elife.deploy_user.username %}

remove-old-drush:
    # Ubuntu 14.04 ships with Drush 5
    # this avoids any conflict
    pkg.removed:
        - name: drush

drush:
    cmd.run:
        - runas: {{ user }}
        # 2016-01-08: registry_rebuild doesn't work/exist yet for drush ~8.0
        #- name: composer global require --no-interaction drush/drush:~7.0\|~8.0
        - name: composer global require --no-interaction drush/drush:~7.0
        - require:
            - remove-old-drush
            - composer

drush-aliases-folder:
    cmd.run:
        - name: mkdir -p /etc/drush/

drush-registry-rebuild:
    cmd.run:
        - runas: {{ user }}
        - name: drush @none pm-download registry_rebuild
        - unless:
            - test -d /home/{{ user }}/.drush/registry_rebuild
        - require:
            - cmd: drush

drush-node-access-rebuild:
    git.latest:
        - user: {{ user }}
        - name: https://github.com/dafeder/node_access_rebuild.git
        - rev: c7d7b0ddb244f317752cdcf883682ecb8b76335d
        - force_checkout: True
        - target: /home/{{ user }}/.drush/node_access_rebuild
        - require:
            - cmd: drush

drush-clear-cache:
    cmd.run:
        - runas: {{ user }}
        - name: drush cache-clear drush
        - listen:
            - cmd: drush-registry-rebuild
            - git: drush-node-access-rebuild
