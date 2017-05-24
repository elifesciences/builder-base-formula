proofreader-php:
    cmd.run:
        - name: composer global --no-interaction require --update-with-dependencies elife/proofreader-php=dev-master 
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - composer
