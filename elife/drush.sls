{% set user = pillar.elife.deploy_user.username %}

drush:
  cmd.run:
    - user: {{ user }}
    # 2016-01-08: registry_rebuild doesn't work/exist yet for drush ~8.0
    #- name: composer global require --no-interaction drush/drush:~7.0\|~8.0
    - name: composer global require --no-interaction drush/drush:~7.0
    - require:
        - composer

drush-aliases-folder:
    cmd.run:
        - name: mkdir -p /etc/drush/

drush-registry-rebuild:
    cmd.run:
        - user: {{ user }}
        - name: drush @none pm-download registry_rebuild
        - unless:
            - test -d /home/{{ user }}/.drush/registry_rebuild
        - require:
            - cmd: drush

drush-node-access-rebuild:
    git.latest:
        - user: {{ user }}
        - name: git://github.com/dafeder/node_access_rebuild.git
        - rev: c7d7b0ddb244f317752cdcf883682ecb8b76335d
        - force_checkout: True
        - target: /home/{{ user }}/.drush/node_access_rebuild
        - require:
            - cmd: drush

drush-clear-cache:
    cmd.run:
        - user: {{ user }}
        - name: drush cache-clear drush
        - listen:
            - cmd: drush-registry-rebuild
            - git: drush-node-access-rebuild
