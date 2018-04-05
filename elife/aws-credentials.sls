# to use this state file, you have to specify
# - pillar.elife.aws.access_key_id
# - pillar.elife.aws.secret_access_key
# for your own project, as a default can't be provided

aws-credentials-deploy-user:
    file.managed:
        - name: /home/{{ pillar.elife.deploy_user.username }}/.aws/credentials
        - source: salt://elife/config/home-deploy-user-.aws-credentials
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - makedirs: True
        - template: jinja
        - require:
            - deploy-user

aws-credentials-www-data-user:
    file.managed:
        - name: /var/www/.aws/credentials
        - source: salt://elife/config/home-deploy-user-.aws-credentials
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - makedirs: True
        - template: jinja
        - onlyif:
            # if user home folder exists
            - test -d /var/www
        # no clear require, since webserver user could be created by uwsgi, php-fpm, nginx...
