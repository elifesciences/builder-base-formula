cron-root-user-emails:
    cron.env_present:
        - name: MAILTO
        - user: root
        - value: ""

deploy-user-user-emails:
    cron.env_present:
        - name: MAILTO
        - user: {{ pillar.elife.deploy_user.username }}
        - value: ""
        - require:
            - deploy-user
