# global defaults for the 'elife' saltstack formula

elife:
    # useful for turning off cron jobs and certain services while developing
    dev: True

    deploy_user:
        username: elife
        email: null
        aws_access: null
        aws_secret: null
        aws_region: us-east-1

    backups:
        # AWS credentials for uploading backups to S3
        s3_access: null 
        s3_secret: null

    webserver:
        username: www-data
        acme_server: https://acme-v01.api.letsencrypt.org/directory
        acme_staging_server: https://acme-staging.api.letsencrypt.org/directory

    web_users:
        '':
            # the default 'open secret' .htaccess user/pass
            # useful for hiding from robots and randoms
            username: username
            password: password
        crazy-:
            # the 'crazy' .htaccess file with a random user+pass
            # useful for hiding stuff even from yourselves
            username: ZWQ5YTZiNzRlZmExZDEzZmZhZDkzYzdm
            password: NjU5YTcyYThlM2Q5NWVlZjYwY2ZjMjRk

    # values that both mysql and psql use
    db_root:
        username: root
        password: root

    redis:
        host: 127.0.0.1
        port: 6379

    logging:
        collectd:
            enabled: False
            # where collectd should send it's stats
            # unencrypted! make sure this is internal traffic or tunnelled
            send_host: 192.168.1.2
            send_port: 25826

        # loggly destination for syslog-ng logs
        # https://www.loggly.com/
        loggly: 
            enabled: False
            host: "logs-01.loggly.com"
            port: 514
            token: null

        # papertrail destination for syslog-ng logs
        # https://papertrailapp.com/
        papertrail:
            enabled: False
            host: "logs3.papertrailapp.com"
            port: 48058

    # postfix using AWS SES as a backend
    postfix_ses_mail:
        smtp: email-smtp.us-east-1.amazonaws.com # change region to suit
        port: 587  # an *unthrottled* SES port. avoid port 25
        from: null # SES verified 'from' address
        user: null # SES-created IAM username
        pass: null # SES-created IAM password

