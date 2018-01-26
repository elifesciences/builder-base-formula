proofreader-php:
    cmd.run:
        - name: composer global --no-interaction require --update-with-dependencies elife/proofreader-php='dev-master#83901bb097b39b0df4ddc9d0e841b685977131ab'
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - composer
